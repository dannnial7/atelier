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

        // Set when the module loads
        // recalculation both know which course this belongs to.
        private int CourseId
        {
            get
            {
                int id;
                return int.TryParse(ViewState["CourseID"]?.ToString(), out id) ? id : 0;
            }
            set
            {
                ViewState["CourseID"] = value;
            }
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
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 0; // 0 indicates Guest / Not Logged In
        }

        private void LoadModule()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT M.CourseID, M.Title, M.ContentType, M.ContentURL, " +
                    "M.Description, M.DurationMins, M.IsPreview, C.Thumbnail " +
                    "FROM Modules M " +
                    "JOIN Courses C ON M.CourseID = C.CourseID " +
                    "WHERE M.ModuleID = @ModuleID", con);
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

                if (dr["Thumbnail"] != DBNull.Value && !string.IsNullOrEmpty(dr["Thumbnail"].ToString()))
                {
                    string thumbUrl = ResolveUrl(dr["Thumbnail"].ToString());
                    divCourseBg.Style["background-image"] = "url('" + thumbUrl + "')";
                }

                string contentType = dr["ContentType"].ToString().ToLower();
                string contentUrl = dr["ContentURL"] == DBNull.Value
                    ? ""
                    : dr["ContentURL"].ToString();
                bool isPreview = dr["IsPreview"] != DBNull.Value && Convert.ToBoolean(dr["IsPreview"]);

                dr.Close();

                lnkBackToCourse.NavigateUrl = "~/CourseDetail.aspx?id=" + CourseId;

                int userId = GetCurrentUserId();
                bool isEnrolled = false;

                if (userId > 0)
                {
                    SqlCommand checkEnroll = new SqlCommand(
                        "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID", con);
                    checkEnroll.Parameters.AddWithValue("@UserID", userId);
                    checkEnroll.Parameters.AddWithValue("@CourseID", CourseId);
                    isEnrolled = Convert.ToInt32(checkEnroll.ExecuteScalar()) > 0;
                }

                // Access Evaluation Logic:
                // Non-preview modules require user to be logged in and enrolled in the course.
                if (!isPreview && !isEnrolled)
                {
                    pnlModuleContent.Visible = false;
                    pnlAccessDenied.Visible = true;

                    if (userId == 0)
                    {
                        lnkRegisterAccess.Visible = true;
                        lnkRegisterAccess.NavigateUrl = "~/Register.aspx?courseId=" + CourseId;
                        lnkLoginAccess.Visible = true;
                        lnkLoginAccess.NavigateUrl = "~/Login.aspx?courseId=" + CourseId;
                        btnEnrollAccess.Visible = false;
                    }
                    else
                    {
                        lnkRegisterAccess.Visible = false;
                        lnkLoginAccess.Visible = false;
                        btnEnrollAccess.Visible = true;

                        SqlCommand priceCmd = new SqlCommand("SELECT Price FROM Courses WHERE CourseID = @CourseID", con);
                        priceCmd.Parameters.AddWithValue("@CourseID", CourseId);
                        object p = priceCmd.ExecuteScalar();
                        decimal price = (p != null) ? Convert.ToDecimal(p) : 0;
                        btnEnrollAccess.Text = (price == 0) ? "Enroll Now (Free)" : "Enroll Now (RM " + price.ToString("F2") + ")";
                    }
                    return;
                }

                // If preview or enrolled -> Access granted
                pnlModuleContent.Visible = true;
                pnlAccessDenied.Visible = false;

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
            }

            if (GetCurrentUserId() > 0)
            {
                LoadCompletionStatus();
                LoadNotes();
            }
            else
            {
                pnlCompleted.Visible = false;
                pnlNotCompleted.Visible = false;
            }
        }

        protected void btnEnrollAccess_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();
            if (userId == 0)
            {
                Response.Redirect("~/Register.aspx?courseId=" + CourseId);
                return;
            }

            decimal price = 0;
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT Price FROM Courses WHERE CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);
                con.Open();
                object p = cmd.ExecuteScalar();
                if (p != null) price = Convert.ToDecimal(p);
            }

            if (price == 0)
            {
                using (SqlConnection con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(
                        "IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID) " +
                        "INSERT INTO Enrollments (UserID, CourseID, Progress, EnrolledAt) VALUES (@UserID, @CourseID, 0, GETDATE())", con);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@CourseID", CourseId);
                    cmd.ExecuteNonQuery();

                    SqlCommand xp = new SqlCommand(
                        "INSERT INTO XPLogs (UserID, PointsEarned, Reason) VALUES (@UserID, 50, 'Enrolled in a course')", con);
                    xp.Parameters.AddWithValue("@UserID", userId);
                    xp.ExecuteNonQuery();
                }
                Response.Redirect("~/ModuleViewer.aspx?id=" + ModuleId);
            }
            else
            {
                Response.Redirect("~/Payment.aspx?courseId=" + CourseId);
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
                    {
                        DateTime completedAt = Convert.ToDateTime(dr["CompletedAt"]);
                        litCompletedAt.Text = completedAt.ToString("MMM d, yyyy");
                    }
                }
                else
                {
                    pnlCompleted.Visible = false;
                    pnlNotCompleted.Visible = true;
                }
                dr.Close();
            }
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();
            if (userId == 0)
            {
                Response.Redirect("~/Register.aspx?courseId=" + CourseId);
                return;
            }

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

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

                    SqlCommand xp = new SqlCommand(
                        "INSERT INTO XPLogs (UserID, PointsEarned, Reason) " +
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
            BadgeHelper.EvaluateBadges(userId);
            LoadCompletionStatus();
        }

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
            int userId = GetCurrentUserId();
            if (userId == 0) return;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT NoteContent, UpdatedAt FROM ModuleNotes " +
                    "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@ModuleID", ModuleId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    txtNotes.Text = dr["NoteContent"].ToString();
                    if (dr["UpdatedAt"] != DBNull.Value)
                    {
                        DateTime updated = Convert.ToDateTime(dr["UpdatedAt"]);
                        litNoteUpdated.Text = "Last saved " + updated.ToString("g");
                    }
                }
                dr.Close();
            }
        }

        protected void btnSaveNotes_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();
            if (userId == 0)
            {
                Response.Redirect("~/Register.aspx?courseId=" + CourseId);
                return;
            }

            if (!Page.IsValid) return;

            string content = txtNotes.Text.Trim();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                SqlCommand check = new SqlCommand(
                    "SELECT COUNT(*) FROM ModuleNotes " +
                    "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                check.Parameters.AddWithValue("@UserID", userId);
                check.Parameters.AddWithValue("@ModuleID", ModuleId);

                int count = Convert.ToInt32(check.ExecuteScalar());

                if (count == 0)
                {
                    SqlCommand insert = new SqlCommand(
                        "INSERT INTO ModuleNotes (UserID, ModuleID, NoteContent, UpdatedAt) " +
                        "VALUES (@UserID, @ModuleID, @NoteContent, GETDATE())", con);
                    insert.Parameters.AddWithValue("@UserID", userId);
                    insert.Parameters.AddWithValue("@ModuleID", ModuleId);
                    insert.Parameters.AddWithValue("@NoteContent", content);
                    insert.ExecuteNonQuery();
                }
                else
                {
                    SqlCommand update = new SqlCommand(
                        "UPDATE ModuleNotes SET NoteContent = @NoteContent, UpdatedAt = GETDATE() " +
                        "WHERE UserID = @UserID AND ModuleID = @ModuleID", con);
                    update.Parameters.AddWithValue("@UserID", userId);
                    update.Parameters.AddWithValue("@ModuleID", ModuleId);
                    update.Parameters.AddWithValue("@NoteContent", content);
                    update.ExecuteNonQuery();
                }
            }

            pnlNoteSaved.Visible = true;
            litNoteUpdated.Text = "Last saved " + DateTime.Now.ToString("g");
        }
    }
}
