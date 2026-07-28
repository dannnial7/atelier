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
            // If the user is already logged in, redirect straight to the dashboard
            if (!IsPostBack && Session["UserID"] != null)
            {
                Response.Redirect("~/Dashboard.aspx");
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

                    // Try BCrypt verification first; fall back to plain-text
                    // comparison for legacy seed data that was not hashed.
                    try
                    {
                        passwordValid = BCrypt.Net.BCrypt.Verify(password, storedHash);
                    }
                    catch
                    {
                        // storedHash is not a valid BCrypt hash — compare as plain text
                        passwordValid = (password == storedHash);
                    }

                    if (passwordValid)
                    {
                        // Set session variables used by Site.Master and other pages
                        Session["UserID"] = Convert.ToInt32(dr["UserID"]).ToString();
                        string fullName = dr["FullName"].ToString();
                        Session["firstName"] = fullName.Split(' ')[0];
                        Session["FullName"] = fullName;
                        Session["Role"] = dr["Role"].ToString();

                        dr.Close();

                        // Admin goes to Admin dashboard, everyone else to learner dashboard
                        if (Session["Role"].ToString() == "Admin")
                            Response.Redirect("~/Admin/Dashboard.aspx");
                        else
                            Response.Redirect("~/Dashboard.aspx");
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

        private void ShowError(string message)
        {
            litError.Text = message;
            pnlError.Visible = true;
        }
    }
}
