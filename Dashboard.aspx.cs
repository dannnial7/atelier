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

                BadgeHelper.EvaluateBadges(userId);
                LoadUserName(userId);
                LoadStats(userId);
                LoadEnrollments(userId);
                LoadBadges(userId);
                LoadCertificates(userId);
                LoadNotifications(userId);
                LoadForumThreads();
            }
        }

        private void LoadCertificates(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT E.CourseID, E.CertificateID, E.CompletedAt, C.Title AS CourseTitle, C.Thumbnail " +
                    "FROM Enrollments E " +
                    "JOIN Courses C ON E.CourseID = C.CourseID " +
                    "WHERE E.UserID = @UserID AND E.CertificateID IS NOT NULL AND E.CertificateID <> '' " +
                    "ORDER BY E.CompletedAt DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", userId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptCertificates.DataSource = dt;
                rptCertificates.DataBind();
                pnlNoCertificates.Visible = (dt.Rows.Count == 0);
            }
        }

        private void LoadNotifications(int userId, bool showAll = false)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                string topClause = showAll ? "" : "TOP 3 ";
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT " + topClause + "Title, Body, CreatedAt, Type " +
                    "FROM Notifications " +
                    "WHERE UserID = @UserID " +
                    "ORDER BY CreatedAt DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", userId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptNotifications.DataSource = dt;
                rptNotifications.DataBind();
                pnlNoNotifications.Visible = (dt.Rows.Count == 0);

                SqlCommand countCmd = new SqlCommand("SELECT COUNT(*) FROM Notifications WHERE UserID = @UserID", con);
                countCmd.Parameters.AddWithValue("@UserID", userId);
                con.Open();
                int totalCount = Convert.ToInt32(countCmd.ExecuteScalar());

                if (btnViewMoreNotifications != null)
                {
                    btnViewMoreNotifications.Visible = (!showAll && totalCount > 3);
                }
            }
        }

        protected void btnViewMoreNotifications_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();
            LoadNotifications(userId, showAll: true);
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
                    "SELECT ISNULL(SUM(PointsEarned), 0) FROM XPLogs WHERE UserID = @UserID", con);
                cmdXP.Parameters.AddWithValue("@UserID", userId);
                lblXP.Text = cmdXP.ExecuteScalar().ToString();

                SqlCommand cmdCourses = new SqlCommand(
                    "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID", con);
                cmdCourses.Parameters.AddWithValue("@UserID", userId);
                lblCourses.Text = cmdCourses.ExecuteScalar().ToString();

                SqlCommand cmdBadges = new SqlCommand(
                    "SELECT COUNT(*) FROM UserBadges WHERE UserID = @UserID", con);
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
                    "SELECT B.BadgeName, B.Description, B.IconURL " +
                    "FROM UserBadges UB " +
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



        private void LoadForumThreads()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT TOP 5 F.ForumID, F.Title, F.CreatedAt, F.ViewCount, F.Pinned, " +
                    "U.FullName, C.Title AS CourseTitle, " +
                    "(SELECT COUNT(*) FROM ForumReplies R WHERE R.ForumID = F.ForumID) AS ReplyCount " +
                    "FROM Forum F " +
                    "JOIN Users U ON F.UserID = U.UserID " +
                    "LEFT JOIN Courses C ON F.CourseID = C.CourseID " +
                    "ORDER BY F.Pinned DESC, F.CreatedAt DESC", con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptForumThreads.DataSource = dt;
                rptForumThreads.DataBind();
                pnlNoForumThreads.Visible = (dt.Rows.Count == 0);
            }
        }
    }
}