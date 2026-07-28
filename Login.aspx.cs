using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Login : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // If already logged in, redirect to destination
                if (Session["UserID"] != null || Session["userID"] != null)
                {
                    RedirectAfterAuth();
                    return;
                }

                // Preserve courseId and returnUrl on link to Register
                string courseIdParam = Request.QueryString["courseId"];
                string returnUrlParam = Request.QueryString["returnUrl"];
                string q = "";
                if (!string.IsNullOrEmpty(courseIdParam)) q += "courseId=" + Server.UrlEncode(courseIdParam);
                if (!string.IsNullOrEmpty(returnUrlParam)) q += (q.Length > 0 ? "&" : "") + "returnUrl=" + Server.UrlEncode(returnUrlParam);
                lnkRegisterLink.HRef = "~/Register.aspx" + (q.Length > 0 ? "?" + q : "");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT UserID, FullName, PasswordHash, Role, IsActive " +
                    "FROM Users WHERE Email = @Email", con);
                cmd.Parameters.AddWithValue("@Email", email);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    bool isActive = Convert.ToBoolean(dr["IsActive"]);
                    if (!isActive)
                    {
                        ShowError("This account has been deactivated. Please contact support.");
                        dr.Close();
                        return;
                    }

                    string storedHash = dr["PasswordHash"].ToString().Trim();
                    bool passwordValid = false;

                    try
                    {
                        passwordValid = BCrypt.Net.BCrypt.Verify(password, storedHash);
                    }
                    catch
                    {
                        passwordValid = (password == storedHash);
                    }

                    if (passwordValid)
                    {
                        int userId = Convert.ToInt32(dr["UserID"]);
                        Session["UserID"] = userId;
                        Session["userID"] = userId;
                        string fullName = dr["FullName"].ToString();
                        Session["firstName"] = fullName.Split(' ')[0];
                        Session["FullName"] = fullName;
                        Session["Role"] = dr["Role"].ToString();

                        dr.Close();

                        RedirectAfterAuth();
                    }
                    else
                    {
                        dr.Close();
                        ShowError("Invalid email or password. Please try again.");
                    }
                }
                else
                {
                    dr.Close();
                    ShowError("Invalid email or password. Please try again.");
                }
            }
        }

        private void RedirectAfterAuth()
        {
            // Admin goes to Admin dashboard
            if (Session["Role"] != null && Session["Role"].ToString() == "Admin")
            {
                Response.Redirect("~/Admin/Dashboard.aspx");
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"] ?? Session["userID"]);

            // 1. Check if courseId is present in query string
            int courseId = 0;
            if (int.TryParse(Request.QueryString["courseId"], out courseId) && courseId > 0)
            {
                using (SqlConnection con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Check if already enrolled
                    SqlCommand checkEnroll = new SqlCommand("SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID", con);
                    checkEnroll.Parameters.AddWithValue("@UserID", userId);
                    checkEnroll.Parameters.AddWithValue("@CourseID", courseId);
                    int isEnrolled = Convert.ToInt32(checkEnroll.ExecuteScalar());

                    if (isEnrolled > 0)
                    {
                        Response.Redirect("~/CourseDetail.aspx?id=" + courseId);
                        return;
                    }

                    // Check course price
                    SqlCommand priceCmd = new SqlCommand("SELECT Price FROM Courses WHERE CourseID = @CourseID", con);
                    priceCmd.Parameters.AddWithValue("@CourseID", courseId);
                    object priceRes = priceCmd.ExecuteScalar();

                    if (priceRes != null)
                    {
                        decimal price = Convert.ToDecimal(priceRes);
                        if (price == 0)
                        {
                            // Free course -> auto enroll!
                            SqlCommand enrollCmd = new SqlCommand(
                                "IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID) " +
                                "INSERT INTO Enrollments (UserID, CourseID, Progress, EnrolledAt) VALUES (@UserID, @CourseID, 0, GETDATE())", con);
                            enrollCmd.Parameters.AddWithValue("@UserID", userId);
                            enrollCmd.Parameters.AddWithValue("@CourseID", courseId);
                            enrollCmd.ExecuteNonQuery();

                            SqlCommand xp = new SqlCommand(
                                "INSERT INTO XPLogs (UserID, PointsEarned, Reason) VALUES (@UserID, 50, 'Enrolled in a course')", con);
                            xp.Parameters.AddWithValue("@UserID", userId);
                            xp.ExecuteNonQuery();

                            Response.Redirect("~/CourseDetail.aspx?id=" + courseId);
                            return;
                        }
                        else
                        {
                            // Paid course -> redirect to payment section
                            Response.Redirect("~/Payment.aspx?courseId=" + courseId);
                            return;
                        }
                    }
                }
            }

            // 2. Check if returnUrl parameter is passed
            string returnUrl = Request.QueryString["returnUrl"];
            if (!string.IsNullOrEmpty(returnUrl))
            {
                Response.Redirect(returnUrl);
                return;
            }

            // 3. Fallback to Learner Dashboard
            Response.Redirect("~/Dashboard.aspx");
        }

        private void ShowError(string message)
        {
            litError.Text = message;
            pnlError.Visible = true;
        }
    }
}
