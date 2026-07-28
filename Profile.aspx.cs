using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace Atelier
{
    public partial class Profile : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfile();
                LoadBillingAccount();
                LoadPaymentHistory();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 2; // TEMPORARY: see Dashboard.aspx.cs
        }

        private void LoadProfile()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT FullName, Email, Bio, ProfilePic, ThemePreferred " +
                    "FROM Users WHERE UserID = @UserID", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    txtFullName.Text = dr["FullName"].ToString();
                    txtEmail.Text = dr["Email"].ToString();
                    txtBio.Text = dr["Bio"] == DBNull.Value ? "" : dr["Bio"].ToString();

                    string pic = dr["ProfilePic"] == DBNull.Value
                        ? ""
                        : dr["ProfilePic"].ToString();

                    imgProfile.ImageUrl = string.IsNullOrEmpty(pic)
                        ? "Images/default-avatar.png"
                        : pic;

                    string theme = dr["ThemePreferred"] == DBNull.Value
                        ? "light"
                        : dr["ThemePreferred"].ToString();

                    ddlTheme.SelectedValue = theme;
                }
                dr.Close();
            }
        }

        private void LoadBillingAccount()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT BillingName, BillingAddress, SavedCardNumber, SavedExpiry " +
                    "FROM Users WHERE UserID = @UserID", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    txtBillingName.Text = dr["BillingName"] == DBNull.Value ? "" : dr["BillingName"].ToString();
                    txtBillingAddress.Text = dr["BillingAddress"] == DBNull.Value ? "" : dr["BillingAddress"].ToString();
                    txtSavedCardNumber.Text = dr["SavedCardNumber"] == DBNull.Value ? "" : dr["SavedCardNumber"].ToString();
                    txtSavedExpiry.Text = dr["SavedExpiry"] == DBNull.Value ? "" : dr["SavedExpiry"].ToString();
                }
                dr.Close();
            }
        }

        private void LoadPaymentHistory()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT P.PaymentID, P.Amount, P.PaidAt, P.Status, P.Cardlastdigits, C.Title AS CourseTitle " +
                    "FROM Payments P " +
                    "JOIN Courses C ON P.CourseID = C.CourseID " +
                    "WHERE P.UserID = @UserID " +
                    "ORDER BY P.PaidAt DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", GetCurrentUserId());

                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptPaymentHistory.DataSource = dt;
                    rptPaymentHistory.DataBind();
                    pnlNoPayments.Visible = false;
                    rptPaymentHistory.Visible = true;
                }
                else
                {
                    pnlNoPayments.Visible = true;
                    rptPaymentHistory.Visible = false;
                }
            }
        }

        protected void btnSaveBilling_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "UPDATE Users SET BillingName = @BillingName, BillingAddress = @BillingAddress, " +
                    "SavedCardNumber = @SavedCardNumber, SavedExpiry = @SavedExpiry " +
                    "WHERE UserID = @UserID", con);
                cmd.Parameters.AddWithValue("@BillingName", txtBillingName.Text.Trim());
                cmd.Parameters.AddWithValue("@BillingAddress", txtBillingAddress.Text.Trim());
                cmd.Parameters.AddWithValue("@SavedCardNumber", txtSavedCardNumber.Text.Trim());
                cmd.Parameters.AddWithValue("@SavedExpiry", txtSavedExpiry.Text.Trim());
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            litBillingSavedMsg.Text = "Billing account saved successfully! Your details will be pre-filled during payment checkout.";
            pnlBillingSaved.Visible = true;
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userId = GetCurrentUserId();
            string picPath = null;

            // A new picture is only saved if one was chosen, so saving other
            // details does not clear the existing image.
            if (fuProfilePic.HasFile)
            {
                picPath = SaveProfilePicture(userId);
                if (picPath == null) return; // an error message has been shown
            }

            // The email is unique in the database, so a duplicate is caught
            // before the update rather than letting the constraint throw.
            if (EmailBelongsToAnotherUser(txtEmail.Text.Trim(), userId))
            {
                ShowError("That email address is already registered to another account.");
                return;
            }

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                string sql =
                    "UPDATE Users SET FullName = @FullName, Email = @Email, " +
                    "Bio = @Bio, ThemePreferred = @Theme";

                if (picPath != null)
                    sql += ", ProfilePic = @ProfilePic";

                sql += " WHERE UserID = @UserID";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Bio", txtBio.Text.Trim());
                cmd.Parameters.AddWithValue("@Theme", ddlTheme.SelectedValue);
                cmd.Parameters.AddWithValue("@UserID", userId);

                if (picPath != null)
                    cmd.Parameters.AddWithValue("@ProfilePic", picPath);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            // The navigation bar greets the user by name, so the session value
            // is refreshed to match what was just saved.
            Session["firstName"] = txtFullName.Text.Trim().Split(' ')[0];

            ShowSuccess("Your profile has been updated.");
            LoadProfile();
        }

        // Uploaded images are renamed using the user's ID so that one learner
        // cannot overwrite another's picture by uploading the same filename.
        private string SaveProfilePicture(int userId)
        {
            string ext = Path.GetExtension(fuProfilePic.FileName).ToLower();

            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
            {
                ShowError("Profile pictures must be a JPG or PNG file.");
                return null;
            }

            if (fuProfilePic.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                ShowError("Profile pictures must be smaller than 2 MB.");
                return null;
            }

            string folder = Server.MapPath("~/Uploads/");
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            string fileName = "profile_" + userId + ext;
            fuProfilePic.SaveAs(Path.Combine(folder, fileName));

            return "Uploads/" + fileName;
        }

        private bool EmailBelongsToAnotherUser(string email, int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Users " +
                    "WHERE Email = @Email AND UserID <> @UserID", con);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        protected void btnChangePwd_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userId = GetCurrentUserId();
            string storedHash;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT PasswordHash FROM Users WHERE UserID = @UserID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();
                object result = cmd.ExecuteScalar();
                storedHash = result == null ? "" : result.ToString();
            }

            // The current password is verified before any change is allowed, so
            // an unattended session cannot be used to take over the account.
            if (!BCrypt.Net.BCrypt.Verify(txtCurrentPwd.Text, storedHash))
            {
                ShowError("Your current password is not correct.");
                return;
            }

            string newHash = BCrypt.Net.BCrypt.HashPassword(txtNewPwd.Text);

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "UPDATE Users SET PasswordHash = @Hash WHERE UserID = @UserID", con);
                cmd.Parameters.AddWithValue("@Hash", newHash);
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            txtCurrentPwd.Text = "";
            txtNewPwd.Text = "";
            txtConfirmPwd.Text = "";

            ShowSuccess("Your password has been changed.");
        }

        private void ShowSuccess(string message)
        {
            litSavedMsg.Text = message;
            pnlSaved.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowError(string message)
        {
            litErrorMsg.Text = message;
            pnlError.Visible = true;
            pnlSaved.Visible = false;
        }
    }
}