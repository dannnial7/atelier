using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Atelier
{
    public partial class Forum : System.Web.UI.Page
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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
                LoadThreads();
            }
        }

        private void LoadCourses()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT CourseID, Title FROM Courses WHERE IsPublished = 1 ORDER BY Title", conn))
            {
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlFilterCourse.Items.Clear();
                    ddlFilterCourse.Items.Add(new ListItem("All courses", "0"));

                    ddlNewCourse.Items.Clear();
                    ddlNewCourse.Items.Add(new ListItem("-- Select a course --", ""));

                    while (dr.Read())
                    {
                        string id = dr["CourseID"].ToString();
                        string title = dr["Title"].ToString();
                        ddlFilterCourse.Items.Add(new ListItem(title, id));
                        ddlNewCourse.Items.Add(new ListItem(title, id));
                    }
                }
            }
        }

        private void LoadThreads()
        {
            int filterCourseId = Convert.ToInt32(ddlFilterCourse.SelectedValue);

            string sql = @"
                SELECT f.ForumID, f.Title, f.Pinned, f.Locked, f.ViewCount, f.CreatedAt,
                       f.UserID, u.FullName, c.Title AS CourseTitle,
                       (SELECT COUNT(*) FROM ForumReplies r WHERE r.ForumID = f.ForumID) AS ReplyCount
                FROM Forum f
                JOIN Users u ON f.UserID = u.UserID
                JOIN Courses c ON f.CourseID = c.CourseID
                WHERE (@CourseID = 0 OR f.CourseID = @CourseID)
                ORDER BY f.Pinned DESC, f.CreatedAt DESC";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@CourseID", filterCourseId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptThreads.DataSource = dt;
                    rptThreads.DataBind();
                    pnlEmpty.Visible = dt.Rows.Count == 0;
                }
            }
        }

        protected void ddlFilterCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadThreads();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string sql = @"INSERT INTO Forum (CourseID, UserID, Title, Body, Pinned, Locked, ViewCount, CreatedAt)
                           VALUES (@CourseID, @UserID, @Title, @Body, 0, 0, 0, GETDATE())";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@CourseID", Convert.ToInt32(ddlNewCourse.SelectedValue));
                cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                cmd.Parameters.AddWithValue("@Title", txtTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@Body", txtBody.Text.Trim());
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ddlNewCourse.SelectedIndex = 0;
            txtTitle.Text = "";
            txtBody.Text = "";

            ShowMessage("Thread posted successfully.");
            LoadThreads();
        }

        protected void rptThreads_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteThread")
            {
                int forumId = Convert.ToInt32(e.CommandArgument);

                int authorUserId = 0;
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand("SELECT UserID FROM Forum WHERE ForumID = @ForumID", conn))
                {
                    cmd.Parameters.AddWithValue("@ForumID", forumId);
                    conn.Open();
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        authorUserId = Convert.ToInt32(obj);
                    }
                }

                if (!CanUserDelete(authorUserId))
                {
                    ShowMessage("You do not have permission to delete this thread.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ForumReplies WHERE ForumID = @ForumID", conn))
                    {
                        cmd.Parameters.AddWithValue("@ForumID", forumId);
                        cmd.ExecuteNonQuery();
                    }
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM Forum WHERE ForumID = @ForumID", conn))
                    {
                        cmd.Parameters.AddWithValue("@ForumID", forumId);
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowMessage("Thread deleted successfully.");
                LoadThreads();
            }
        }

        private void ShowMessage(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = true;
        }
    }
}