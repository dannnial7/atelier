using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class ManageForum : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null)
            {
                Response.Redirect("~/Login.aspx");
            }

            if (Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Login.aspx");
            }

            if (!IsPostBack)
            {
                LoadThreads();
                LoadReportedPosts();
            }
        }

        private void LoadThreads()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT F.ForumID, F.Title, " +
                "U.FullName, C.Title AS CourseTitle, " +
                "F.CreatedAt, " +
                "(SELECT COUNT(*) FROM ForumReplies R " +
                "WHERE R.ForumID = F.ForumID) " +
                "AS ReplyCount " +
                "FROM Forum F " +
                "JOIN Users U ON F.UserID = U.UserID " +
                "JOIN Courses C ON F.CourseID = C.CourseID " +
                "ORDER BY F.CreatedAt DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvThreads.DataSource = dt;
            gvThreads.DataBind();

            lblThreadCount.Text =
                dt.Rows.Count.ToString();
        }

        private void LoadReportedPosts()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT R.ReplyID, R.Body, " +
                "U.FullName, R.ReportReason, " +
                "R.PostedAt " +
                "FROM ForumReplies R " +
                "JOIN Users U ON R.UserID = U.UserID " +
                "WHERE R.IsReported = 1 " +
                "ORDER BY R.PostedAt DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvReported.DataSource = dt;
            gvReported.DataBind();

            lblReportedCount.Text =
                dt.Rows.Count.ToString();
        }

        protected void btnShowThreads_Click(
            object sender, EventArgs e)
        {
            threadsPanel.Style["display"] = "block";
            reportedPanel.Style["display"] = "none";
        }

        protected void btnShowReported_Click(
            object sender, EventArgs e)
        {
            threadsPanel.Style["display"] = "none";
            reportedPanel.Style["display"] = "block";
        }

        protected void gvThreads_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteThread")
            {
                int ForumID = Convert.ToInt32(
                    e.CommandArgument);

                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM Forum " +
                    "WHERE ForumID = " + ForumID,
                    con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Thread deleted successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadThreads();
            }
        }

        protected void gvReported_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            int replyID = Convert.ToInt32(
                e.CommandArgument);

            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            if (e.CommandName == "DismissReport")
            {
                SqlCommand cmd = new SqlCommand(
                    "UPDATE ForumReplies SET " +
                    "IsReported = 0, " +
                    "ReportReason = NULL " +
                    "WHERE ReplyID = " + replyID, con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Report dismissed successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;
            }
            else if (e.CommandName == "DeleteReply")
            {
                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM ForumReplies " +
                    "WHERE ReplyID = " + replyID, con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Post deleted successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;
            }

            LoadReportedPosts();
        }
    }
}