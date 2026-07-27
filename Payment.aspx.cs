using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Payment : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        private int CourseId
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["courseId"], out id) ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Require login
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (CourseId == 0)
                {
                    ShowError("No course selected. Please choose a course first.");
                    pnlPayment.Visible = false;
                    return;
                }

                LoadCourseDetails();
                CheckEnrollment();
            }
        }

        private void LoadCourseDetails()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT C.Title, C.Price, C.Difficulty, CC.CategoryName " +
                    "FROM Courses C " +
                    "JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "WHERE C.CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    decimal price = Convert.ToDecimal(dr["Price"]);
                    litCourseTitle.Text = dr["Title"].ToString();
                    litPrice.Text = price.ToString("F2");
                    litCategory.Text = dr["CategoryName"].ToString();
                    litDifficulty.Text = dr["Difficulty"].ToString();

                    // If free course, bypass card input UI
                    if (price == 0)
                    {
                        pnlCardInputs.Visible = false;
                        btnPay.Text = "Confirm Free Enrollment";
                    }
                }
                else
                {
                    ShowError("Course not found.");
                    pnlPayment.Visible = false;
                }
                dr.Close();
            }
        }

        private void CheckEnrollment()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Enrollments " +
                    "WHERE UserID = @UserID AND CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());

                if (count > 0)
                {
                    pnlPayment.Visible = false;
                    pnlAlreadyEnrolled.Visible = true;
                }
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                // Get the course price
                SqlCommand priceCmd = new SqlCommand(
                    "SELECT Price FROM Courses WHERE CourseID = @CourseID", con);
                priceCmd.Parameters.AddWithValue("@CourseID", CourseId);
                decimal amount = Convert.ToDecimal(priceCmd.ExecuteScalar());

                if (amount > 0)
                {
                    if (!Page.IsValid) return;
                    string cardNumber = txtCardNumber.Text.Trim();
                    string last4 = cardNumber.Substring(cardNumber.Length - 4);

                    // Insert payment record (only stores last 4 digits of card)
                    SqlCommand payCmd = new SqlCommand(
                        "INSERT INTO Payments (UserID, CourseID, Amount, Cardlastdigits) " +
                        "VALUES (@UserID, @CourseID, @Amount, @Last4)", con);
                    payCmd.Parameters.AddWithValue("@UserID", userId);
                    payCmd.Parameters.AddWithValue("@CourseID", CourseId);
                    payCmd.Parameters.AddWithValue("@Amount", amount);
                    payCmd.Parameters.AddWithValue("@Last4", last4);
                    payCmd.ExecuteNonQuery();
                }
                else
                {
                    // Record free enrollment transaction
                    SqlCommand payCmd = new SqlCommand(
                        "INSERT INTO Payments (UserID, CourseID, Amount, Cardlastdigits) " +
                        "VALUES (@UserID, @CourseID, 0.00, 'FREE')", con);
                    payCmd.Parameters.AddWithValue("@UserID", userId);
                    payCmd.Parameters.AddWithValue("@CourseID", CourseId);
                    payCmd.ExecuteNonQuery();
                }

                // Enroll the user in the course
                SqlCommand enrollCmd = new SqlCommand(
                    "INSERT INTO Enrollments (UserID, CourseID) " +
                    "VALUES (@UserID, @CourseID)", con);
                enrollCmd.Parameters.AddWithValue("@UserID", userId);
                enrollCmd.Parameters.AddWithValue("@CourseID", CourseId);
                enrollCmd.ExecuteNonQuery();

                // Redirect to success page
                Response.Redirect("~/PaymentSuccess.aspx?courseId=" + CourseId);
            }
        }

        private void ShowError(string message)
        {
            litError.Text = message;
            pnlError.Visible = true;
        }
    }
}
