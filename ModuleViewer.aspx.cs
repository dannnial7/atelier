using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class ModuleViewer : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        private int ModuleId
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        // Set when the module loads, so the breadcrumb and progress
        // recalculation both know which course this belongs to.
        private int CourseId
        {
            get { return ViewState["CourseId"] != null ? (int)ViewState["CourseId"] : 0; }
            set { ViewState["CourseId"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (ModuleId == 0)
                {
                    pnlModule.Visible = false;
                    pnlNotFound.Visible = true;
                    return;
                }

                LoadModule();
                LoadCompletionStatus();
                LoadNotes();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 2; // TEMPORARY: see Dashboard.aspx.cs
        }

        private void LoadModule()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT CourseID, Title, ContentType, ContentURL, " +
                    "Description, DurationMins " +
                    "FROM Modules WHERE ModuleID = @ModuleID", con);
                cmd.Parameters.AddWithValue("@ModuleID", ModuleId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (!dr.Read())
                {
                    dr.Close();
                    pnlModule.Visible = false;
                    pnlNotFound.Visible = true;
                    return;
                }

                CourseId = Convert.ToInt32(dr["CourseID"]);
                litTitle.Text = dr["Title"].ToString();
                litDuration.Text = dr["DurationMins"].ToString();
                litDescription.Text = dr["Description"].ToString().Replace("\n", "<br />");

                string contentType = dr["ContentType"].ToString().ToLower();
                string contentUrl = dr["ContentURL"] == DBNull.Value
                    ? ""
                    : dr["ContentURL"].ToString();

                lnkBackToCourse.NavigateUrl = "~/CourseDetail.aspx?id=" + CourseId;

                // The database stores the delivery format against each module,
                // so the page renders whichever panel matches rather than
                // assuming every module is a video.
                if (contentType == "video")
                {
                    litType.Text = "Video";
                    litVideo.Text = contentUrl;
                    pnlVideo.Visible = true;
                }
                else if (contentType == "pdf")
                {
                    litType.Text = "PDF";
                    lnkPdf.NavigateUrl = contentUrl;
                    pnlPdf.Visible = true;
                }
                else
                {
                    litType.Text = "Reading";
                }

                dr.Close();
            }
        }

        private void LoadCompletionStatus()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT IsCompleted, CompletedAt FROM ModuleProgress " +
                    "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());
                cmd.Parameters.AddWithValue("@ModuleID", ModuleId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read() && Convert.ToBoolean(dr["IsCompleted"]))
                {
                    pnlCompleted.Visible = true;
                    pnlNotCompleted.Visible = false;

                    if (dr["CompletedAt"] != DBNull.Value)
                        litCompletedAt.Text =
                            Convert.ToDateTime(dr["CompletedAt"]).ToString("dd MMM yyyy");
                }
                dr.Close();
            }
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                // Guard against double-awarding if the learner reloads
                // and clicks again.
                SqlCommand check = new SqlCommand(
                    "SELECT COUNT(*) FROM ModuleProgress " +
                    "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                check.Parameters.AddWithValue("@UserID", userId);
                check.Parameters.AddWithValue("@ModuleID", ModuleId);

                int existing = Convert.ToInt32(check.ExecuteScalar());

                if (existing == 0)
                {
                    SqlCommand insert = new SqlCommand(
                        "INSERT INTO ModuleProgress (UserID, ModuleID, IsCompleted, CompletedAt) " +
                        "VALUES (@UserID, @ModuleID, 1, GETDATE())", con);
                    insert.Parameters.AddWithValue("@UserID", userId);
                    insert.Parameters.AddWithValue("@ModuleID", ModuleId);
                    insert.ExecuteNonQuery();

                    // Completing a module awards experience points, which the
                    // dashboard and leaderboard both read from this log.
                    SqlCommand xp = new SqlCommand(
                        "INSERT INTO XPLogs (UserID, PointsEraned, Reason) " +
                        "VALUES (@UserID, 50, 'Completed a module')", con);
                    xp.Parameters.AddWithValue("@UserID", userId);
                    xp.ExecuteNonQuery();

                    SqlCommand notify = new SqlCommand(
                        "INSERT INTO Notifications (UserID, Title, Body, Type) " +
                        "VALUES (@UserID, 'Module completed', " +
                        "'You earned 50 XP for completing a module.', 'badge')", con);
                    notify.Parameters.AddWithValue("@UserID", userId);
                    notify.ExecuteNonQuery();
                }
                else
                {
                    SqlCommand update = new SqlCommand(
                        "UPDATE ModuleProgress SET IsCompleted = 1, CompletedAt = GETDATE() " +
                        "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                    update.Parameters.AddWithValue("@UserID", userId);
                    update.Parameters.AddWithValue("@ModuleID", ModuleId);
                    update.ExecuteNonQuery();
                }
            }

            RecalculateCourseProgress(userId);
            LoadCompletionStatus();
        }

        // Course progress is derived from how many of its modules the learner
        // has finished, so it stays correct even if modules are added later.
        private void RecalculateCourseProgress(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(
                    "SELECT " +
                    "  (SELECT COUNT(*) FROM Modules WHERE CourseID = @CourseID) AS Total, " +
                    "  (SELECT COUNT(*) FROM ModuleProgress MP " +
                    "     JOIN Modules M ON MP.ModuleID = M.ModuleID " +
                    "     WHERE M.CourseID = @CourseID AND MP.UserID = @UserID " +
                    "       AND MP.IsCompleted = 1) AS Done", con);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);
                cmd.Parameters.AddWithValue("@UserID", userId);

                SqlDataReader dr = cmd.ExecuteReader();
                int total = 0, done = 0;

                if (dr.Read())
                {
                    total = Convert.ToInt32(dr["Total"]);
                    done = Convert.ToInt32(dr["Done"]);
                }
                dr.Close();

                if (total > 0)
                {
                    int percent = (int)Math.Round((double)done / total * 100);

                    SqlCommand upd = new SqlCommand(
                        "UPDATE Enrollments SET Progress = @Progress " +
                        "WHERE UserID = @UserID AND CourseID = @CourseID", con);
                    upd.Parameters.AddWithValue("@Progress", percent);
                    upd.Parameters.AddWithValue("@UserID", userId);
                    upd.Parameters.AddWithValue("@CourseID", CourseId);
                    upd.ExecuteNonQuery();
                }
            }
        }

        private void LoadNotes()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT NoteText, UpdatedAt FROM NOTES " +
                    "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());
                cmd.Parameters.AddWithValue("@ModuleID", ModuleId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    txtNotes.Text = dr["NoteText"].ToString();
                    litNoteUpdated.Text = "Last saved " +
                        Convert.ToDateTime(dr["UpdatedAt"]).ToString("dd MMM yyyy, h:mm tt");
                }
                dr.Close();
            }
        }

        protected void btnSaveNotes_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userId = GetCurrentUserId();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                // Only one note is kept per module, so an existing note is
                // updated rather than a second row inserted.
                SqlCommand check = new SqlCommand(
                    "SELECT COUNT(*) FROM NOTES " +
                    "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                check.Parameters.AddWithValue("@UserID", userId);
                check.Parameters.AddWithValue("@ModuleID", ModuleId);

                if (Convert.ToInt32(check.ExecuteScalar()) > 0)
                {
                    SqlCommand upd = new SqlCommand(
                        "UPDATE NOTES SET NoteText = @NoteText, UpdatedAt = GETDATE() " +
                        "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                    upd.Parameters.AddWithValue("@NoteText", txtNotes.Text.Trim());
                    upd.Parameters.AddWithValue("@UserID", userId);
                    upd.Parameters.AddWithValue("@ModuleID", ModuleId);
                    upd.ExecuteNonQuery();
                }
                else
                {
                    SqlCommand ins = new SqlCommand(
                        "INSERT INTO NOTES (UserID, ModuleID, NoteText) " +
                        "VALUES (@UserID, @ModuleID, @NoteText)", con);
                    ins.Parameters.AddWithValue("@UserID", userId);
                    ins.Parameters.AddWithValue("@ModuleID", ModuleId);
                    ins.Parameters.AddWithValue("@NoteText", txtNotes.Text.Trim());
                    ins.ExecuteNonQuery();
                }
            }

            pnlNoteSaved.Visible = true;
            LoadNotes();
        }
    }
}
