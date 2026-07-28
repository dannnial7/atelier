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
            // Already logged-in users don't need to register again
            if (!IsPostBack && Session["UserID"] != null)
            {
                Response.Redirect("~/Dashboard.aspx");
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

                // Check if email already exists
                SqlCommand checkCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Users WHERE Email = @Email", con);
                checkCmd.Parameters.AddWithValue("@Email", email);
                int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (exists > 0)
                {
                    ShowError("An account with this email address already exists. Please sign in instead.");
                    return;
                }

                // Hash the password using BCrypt
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                // Insert new user (Role defaults to 'Learner' in the table definition)
                SqlCommand insertCmd = new SqlCommand(
                    "INSERT INTO Users (FullName, Email, PasswordHash) " +
                    "OUTPUT INSERTED.UserID " +
                    "VALUES (@FullName, @Email, @PasswordHash)", con);
                insertCmd.Parameters.AddWithValue("@FullName", fullName);
                insertCmd.Parameters.AddWithValue("@Email", email);
                insertCmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                int newUserId = Convert.ToInt32(insertCmd.ExecuteScalar());

                // Auto-login after successful registration
                Session["UserID"] = newUserId;
                Session["firstName"] = fullName.Split(' ')[0];
                Session["FullName"] = fullName;
                Session["Role"] = "Learner";

                // Check if registration was triggered from a specific course (e.g. preview module / catalogue)
                int courseId = 0;
                if (int.TryParse(Request.QueryString["courseId"], out courseId) && courseId > 0)
                {
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
                            enrollCmd.Parameters.AddWithValue("@UserID", newUserId);
                            enrollCmd.Parameters.AddWithValue("@CourseID", courseId);
                            enrollCmd.ExecuteNonQuery();

                            SqlCommand xp = new SqlCommand(
                                "INSERT INTO XPLogs (UserID, PointsEarned, Reason) VALUES (@UserID, 50, 'Enrolled in a course')", con);
                            xp.Parameters.AddWithValue("@UserID", newUserId);
                            xp.ExecuteNonQuery();

                            SqlCommand notify = new SqlCommand(
                                "INSERT INTO Notifications (UserID, Title, Body, Type) " +
                                "VALUES (@UserID, 'Welcome & Enrolled!', 'You have registered and enrolled in your course successfully.', 'course')", con);
                            notify.Parameters.AddWithValue("@UserID", newUserId);
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

                Response.Redirect("~/Dashboard.aspx");
            }
        }

        private void ShowError(string message)
        {
            litError.Text = message;
            pnlError.Visible = true;
        }
    }
}
