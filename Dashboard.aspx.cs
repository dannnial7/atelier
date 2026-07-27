using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace Atelier
{
    public partial class Dashboard : Page
    {
        // Reads the connection string once so every method below can reuse it.
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int userId = GetCurrentUserId();

                LoadUserName(userId);
                LoadStats(userId);
                LoadEnrollments(userId);
                LoadBadges(userId);
                LoadNotifications(userId);
            }
        }

        // TEMPORARY: falls back to UserID 2 (Dibyajoti Roy) while Login.aspx
        // is still being built. Once login sets Session["UserID"], this
        // returns the real logged-in user automatically.
        // TODO: replace the fallback with a redirect to Login.aspx.
        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 2;
        }

        private void LoadUserName(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT FullName FROM Users WHERE UserID = @UserID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();
                object result = cmd.ExecuteScalar();
                litName.Text = result != null ? result.ToString() : "Learner";
            }
        }

        private void LoadStats(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                // Total XP is summed from the log rather than stored on the user,
                // so it always reflects every point ever awarded.
                SqlCommand cmdXP = new SqlCommand(
                    "SELECT ISNULL(SUM(PointsEraned), 0) FROM XPLogs WHERE UserID = @UserID", con);
                cmdXP.Parameters.AddWithValue("@UserID", userId);
                lblXP.Text = cmdXP.ExecuteScalar().ToString();

                SqlCommand cmdCourses = new SqlCommand(
                    "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID", con);
                cmdCourses.Parameters.AddWithValue("@UserID", userId);
                lblCourses.Text = cmdCourses.ExecuteScalar().ToString();

                SqlCommand cmdBadges = new SqlCommand(
                    "SELECT COUNT(*) FROM UserBages WHERE UserID = @UserID", con);
                cmdBadges.Parameters.AddWithValue("@UserID", userId);
                lblBadges.Text = cmdBadges.ExecuteScalar().ToString();
            }
        }

        private void LoadEnrollments(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT C.CourseID, C.Title, C.Thumbnail, C.Difficulty, " +
                    "CC.CategoryName, E.Progress AS Progress " +
                    "FROM Enrollments E " +
                    "JOIN Courses C ON E.CourseID = C.CourseID " +
                    "JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "WHERE E.UserID = @UserID " +
                    "ORDER BY E.EnrolledAt DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", userId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptEnrollments.DataSource = dt;
                rptEnrollments.DataBind();
                pnlNoCourses.Visible = (dt.Rows.Count == 0);
            }
        }

        private void LoadBadges(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT B.BadgeName, B.Description " +
                    "FROM UserBages UB " +
                    "JOIN Badges B ON UB.BadgeID = B.BadgeID " +
                    "WHERE UB.UserID = @UserID " +
                    "ORDER BY UB.EarnedAt DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", userId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptBadges.DataSource = dt;
                rptBadges.DataBind();
                pnlNoBadges.Visible = (dt.Rows.Count == 0);
            }
        }

        private void LoadNotifications(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT TOP 5 Title, Body, CreatedAt " +
                    "FROM Notifications " +
                    "WHERE UserID = @UserID " +
                    "ORDER BY CreatedAt DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", userId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptNotifications.DataSource = dt;
                rptNotifications.DataBind();
                pnlNoNotifications.Visible = (dt.Rows.Count == 0);
            }
        }
    }
}