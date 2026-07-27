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
                return Convert.ToInt32(Session["UserID"]);
            return 2; // default to Roy
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
                       f.UserID, u.FullName, c.Title AS CourseTitle
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
                    string body = dr["Body"].ToString();
                    bool pinned = (bool)dr["Pinned"];
                    _threadLocked = (bool)dr["Locked"];
                    _threadOwnerId = (int)dr["UserID"];

                    litTitle.Text = Server.HtmlEncode(title);
                    litBody.Text = Server.HtmlEncode(body);
                    litPinned.Text = pinned ? "<span class='badge'>Pinned</span> " : "";
                    litLocked.Text = _threadLocked ? "<span class='badge'>Locked</span> " : "";
                    litAuthor.Text = Server.HtmlEncode(dr["FullName"].ToString());
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

            bool isOwner = _threadOwnerId == CurrentUserId;
            pnlOwnerActions.Visible = isOwner;

            pnlReplyForm.Visible = !_threadLocked;
            pnlLocked.Visible = _threadLocked;
        }

        private void LoadReplies()
        {
            string sql = @"
                SELECT r.ReplyID, r.Body, r.PostedAt, r.UserID, u.FullName
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

        protected void btnDeleteThread_Click(object sender, EventArgs e)
        {
            string sql = "DELETE FROM Forum WHERE ForumID = @ForumID AND UserID = @UserID";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ForumID", ForumId);
                cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                conn.Open();
                int rows = cmd.ExecuteNonQuery();
                if (rows > 0)
                {
                    Response.Redirect("Forum.aspx");
                    return;
                }
            }
            ShowMessage("You can only delete your own thread.");
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteReply")
            {
                int replyId = Convert.ToInt32(e.CommandArgument);

                string sql = "DELETE FROM ForumReplies WHERE ReplyID = @ReplyID AND UserID = @UserID";
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ReplyID", replyId);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
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