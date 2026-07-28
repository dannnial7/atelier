using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Register : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] != null || Session["userID"] != null)
                {
                    RedirectAfterAuth();
                    return;
                }

                // Preserve courseId and returnUrl on link to Login
                string courseIdParam = Request.QueryString["courseId"];
                string returnUrlParam = Request.QueryString["returnUrl"];
                string q = "";
                if (!string.IsNullOrEmpty(courseIdParam)) q += "courseId=" + Server.UrlEncode(courseIdParam);
                if (!string.IsNullOrEmpty(returnUrlParam)) q += (q.Length > 0 ? "&" : "") + "returnUrl=" + Server.UrlEncode(returnUrlParam);
                lnkLoginLink.HRef = "~/Login.aspx" + (q.Length > 0 ? "?" + q : "");
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                SqlCommand checkCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Users WHERE Email = @Email", con);
                checkCmd.Parameters.AddWithValue("@Email", email);
                int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (exists > 0)
                {
                    ShowError("An account with this email address already exists. Please sign in instead.");
                    return;
                }

                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                SqlCommand insertCmd = new SqlCommand(
                    "INSERT INTO Users (FullName, Email, PasswordHash) " +
                    "OUTPUT INSERTED.UserID " +
                    "VALUES (@FullName, @Email, @PasswordHash)", con);
                insertCmd.Parameters.AddWithValue("@FullName", fullName);
                insertCmd.Parameters.AddWithValue("@Email", email);
                insertCmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                int newUserId = Convert.ToInt32(insertCmd.ExecuteScalar());

                Session["UserID"] = newUserId;
                Session["userID"] = newUserId;
                Session["firstName"] = fullName.Split(' ')[0];
                Session["FullName"] = fullName;
                Session["Role"] = "Learner";

                RedirectAfterAuth();
            }
        }

        private void RedirectAfterAuth()
        {
            int userId = Convert.ToInt32(Session["UserID"] ?? Session["userID"]);

            // 1. Check if courseId parameter is present
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

                    SqlCommand priceCmd = new SqlCommand("SELECT Price FROM Courses WHERE CourseID = @CourseID", con);
                    priceCmd.Parameters.AddWithValue("@CourseID", courseId);
                    object priceRes = priceCmd.ExecuteScalar();

                    if (priceRes != null)
                    {
                        decimal price = Convert.ToDecimal(priceRes);
                        if (price == 0)
                        {
                            // Free course -> auto enroll new user!
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

                            SqlCommand notify = new SqlCommand(
                                "INSERT INTO Notifications (UserID, Title, Body, Type) " +
                                "VALUES (@UserID, 'Welcome & Enrolled!', 'You have registered and enrolled in your course successfully.', 'course')", con);
                            notify.Parameters.AddWithValue("@UserID", userId);
                            notify.ExecuteNonQuery();

                            Response.Redirect("~/CourseDetail.aspx?id=" + courseId);
                            return;
                        }
                        else
                        {
                            // Paid course -> redirect to payment
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

            Response.Redirect("~/Dashboard.aspx");
        }

        private void ShowError(string message)
        {
            litError.Text = message;
            pnlError.Visible = true;
        }
    }
}
