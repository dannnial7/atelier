using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Atelier
{
    public partial class ForumThread : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        // Temporary auth fallback — replace once Danial's Login sets the session
        public int CurrentUserId => GetCurrentUserId();

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
            {
                int id;
                if (int.TryParse(Session["UserID"].ToString(), out id))
                    return id;
            }
            return 0;
        }

        public bool CanUserDelete(object authorUserIdObj)
        {
            if (Session["UserID"] == null) return false;

            int currentUserId;
            if (!int.TryParse(Session["UserID"].ToString(), out currentUserId) || currentUserId <= 0)
                return false;

            string role = Session["Role"] != null ? Session["Role"].ToString() : "";
            if (role.Equals("Admin", StringComparison.OrdinalIgnoreCase)) return true;

            if (authorUserIdObj != null && authorUserIdObj != DBNull.Value)
            {
                int authorUserId = Convert.ToInt32(authorUserIdObj);
                if (currentUserId == authorUserId) return true;
            }

            return false;
        }

        private int ForumId
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        private bool _threadLocked = false;
        private int _threadOwnerId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (ForumId == 0)
            {
                pnlThread.Visible = false;
                pnlNotFound.Visible = true;
                return;
            }

            if (!IsPostBack)
            {
                IncrementViewCount();
            }

            LoadThread();
            LoadReplies();
        }

        private void IncrementViewCount()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Forum SET ViewCount = ViewCount + 1 WHERE ForumID = @ForumID", conn))
            {
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void LoadThread()
        {
            string sql = @"
                SELECT f.ForumID, f.Title, f.Body, f.Pinned, f.Locked, f.ViewCount, f.CreatedAt,
                       f.UserID, u.FullName, ISNULL(u.Bio, '') AS Bio, ISNULL(u.ProfilePic, '') AS ProfilePic,
                       (SELECT ISNULL(SUM(PointsEarned), 0) FROM XPLogs WHERE UserID = u.UserID) AS TotalXP,
                       (SELECT COUNT(*) FROM UserBadges WHERE UserID = u.UserID) AS BadgeCount,
                       c.Title AS CourseTitle
                FROM Forum f
                JOIN Users u ON f.UserID = u.UserID
                JOIN Courses c ON f.CourseID = c.CourseID
                WHERE f.ForumID = @ForumID";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        pnlThread.Visible = false;
                        pnlNotFound.Visible = true;
                        return;
                    }

                    string title = dr["Title"].ToString();
                    string body = dr["Body"].ToString().TrimStart(' ', '\t', '\r', '\n', '\u00A0');
                    bool pinned = (bool)dr["Pinned"];
                    _threadLocked = (bool)dr["Locked"];
                    _threadOwnerId = (int)dr["UserID"];

                    litTitle.Text = Server.HtmlEncode(title);
                    litBody.Text = Server.HtmlEncode(body);
                    litPinned.Text = pinned ? "<span class='badge'>Pinned</span> " : "";
                    litLocked.Text = _threadLocked ? "<span class='badge'>Locked</span> " : "";
                    litAuthor.Text = string.Format("<a href=\"UserProfile.aspx?id={5}\" onclick='openUserPreview(\"{0}\", \"{1}\", \"{2}\", \"{3}\", \"{4}\"); return false;' style='color:inherit;font-weight:600;text-decoration:underline;'>{0}</a>", Server.HtmlEncode(dr["FullName"].ToString()), Server.HtmlEncode(dr["Bio"].ToString().Replace("\r", "").Replace("\n", " ")), dr["TotalXP"], dr["BadgeCount"], dr["ProfilePic"], _threadOwnerId);
                    litCourse.Text = Server.HtmlEncode(dr["CourseTitle"].ToString());
                    litDate.Text = Convert.ToDateTime(dr["CreatedAt"]).ToString("dd MMM yyyy, HH:mm");
                    litViews.Text = dr["ViewCount"].ToString();

                    if (!IsPostBack)
                    {
                        txtEditTitle.Text = title;
                        txtEditBody.Text = body;
                    }
                }
            }

            bool isOwnerOrAdmin = CanUserDelete(_threadOwnerId);
            pnlOwnerActions.Visible = isOwnerOrAdmin;

            bool isGuest = Session["firstName"] == null || Session["UserID"] == null;
            pnlReplyForm.Visible = !_threadLocked && !isGuest;
            pnlLocked.Visible = _threadLocked;
            pnlGuestNotice.Visible = isGuest && !_threadLocked;
        }

        private void LoadReplies()
        {
            string sql = @"
                SELECT r.ReplyID, r.Body, r.PostedAt, r.UserID, u.FullName,
                       ISNULL(u.Bio, '') AS Bio, ISNULL(u.ProfilePic, '') AS ProfilePic,
                       (SELECT ISNULL(SUM(PointsEarned), 0) FROM XPLogs WHERE UserID = u.UserID) AS TotalXP,
                       (SELECT COUNT(*) FROM UserBadges WHERE UserID = u.UserID) AS BadgeCount
                FROM ForumReplies r
                JOIN Users u ON r.UserID = u.UserID
                WHERE r.ForumID = @ForumID
                ORDER BY r.PostedAt ASC";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptReplies.DataSource = dt;
                    rptReplies.DataBind();
                    pnlNoReplies.Visible = dt.Rows.Count == 0;
                }
            }
        }

        protected void btnShowEdit_Click(object sender, EventArgs e)
        {
            pnlEdit.Visible = true;
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            pnlEdit.Visible = false;
        }

        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            if (Session["firstName"] == null || Session["UserID"] == null)
            {
                ShowMessage("Please sign in or register an account to reply to discussions.");
                return;
            }

            if (!Page.IsValid) return;

            if (IsThreadLocked())
            {
                ShowMessage("This thread is locked. Reply not posted.");
                return;
            }

            string sql = @"INSERT INTO ForumReplies (ForumID, UserID, Body, IsReported, PostedAt)
                           VALUES (@ForumID, @UserID, @Body, 0, GETDATE())";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                cmd.Parameters.AddWithValue("@Body", txtReply.Text.Trim());
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            txtReply.Text = "";
            ShowMessage("Reply posted.");
            LoadReplies();
        }

        protected void btnSaveEdit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string sql = @"UPDATE Forum SET Title = @Title, Body = @Body
                           WHERE ForumID = @ForumID AND UserID = @UserID";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Title", txtEditTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@Body", txtEditBody.Text.Trim());
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            pnlEdit.Visible = false;
            ShowMessage("Thread updated.");
            LoadThread();
        }

        protected void btnReportThread_Click(object sender, EventArgs e)
        {
            if (Session["firstName"] == null || Session["UserID"] == null)
            {
                ShowMessage("Please sign in or register an account to report threads.");
                return;
            }

            pnlReportModal.Visible = true;
        }

        protected void btnCancelReport_Click(object sender, EventArgs e)
        {
            pnlReportModal.Visible = false;
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            if (Session["firstName"] == null || Session["UserID"] == null)
            {
                ShowMessage("Please sign in or register an account to report threads.");
                pnlReportModal.Visible = false;
                return;
            }

            string reason = ddlReportReason.SelectedValue;
            int reporterId = CurrentUserId;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("UPDATE Forum SET IsReported = 1, ReportedBy = @ReportedBy, ReportReason = @ReportReason WHERE ForumID = @ForumID", conn))
            {
                cmd.Parameters.AddWithValue("@ReportedBy", reporterId);
                cmd.Parameters.AddWithValue("@ReportReason", reason);
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            pnlReportModal.Visible = false;
            ShowMessage("Thank you. This thread has been reported to administrators for further action.");
        }

        protected void btnDeleteThread_Click(object sender, EventArgs e)
        {
            if (!CanUserDelete(_threadOwnerId))
            {
                ShowMessage("You do not have permission to delete this thread.");
                return;
            }

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM ForumReplies WHERE ForumID = @ForumID", conn))
                {
                    cmd.Parameters.AddWithValue("@ForumID", ForumId);
                    cmd.ExecuteNonQuery();
                }
                using (SqlCommand cmd = new SqlCommand("DELETE FROM Forum WHERE ForumID = @ForumID", conn))
                {
                    cmd.Parameters.AddWithValue("@ForumID", ForumId);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        Response.Redirect("Forum.aspx");
                        return;
                    }
                }
            }
            ShowMessage("Unable to delete thread.");
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteReply")
            {
                int replyId = Convert.ToInt32(e.CommandArgument);

                int replyAuthorId = 0;
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand("SELECT UserID FROM ForumReplies WHERE ReplyID = @ReplyID", conn))
                {
                    cmd.Parameters.AddWithValue("@ReplyID", replyId);
                    conn.Open();
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        replyAuthorId = Convert.ToInt32(obj);
                    }
                }

                if (!CanUserDelete(replyAuthorId))
                {
                    ShowMessage("You do not have permission to delete this reply.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand("DELETE FROM ForumReplies WHERE ReplyID = @ReplyID", conn))
                {
                    cmd.Parameters.AddWithValue("@ReplyID", replyId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Reply deleted.");
                LoadReplies();
            }
        }

        private bool IsThreadLocked()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Locked FROM Forum WHERE ForumID = @ForumID", conn))
            {
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null && (bool)result;
            }
        }

        private void ShowMessage(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = true;
        }
    }
}