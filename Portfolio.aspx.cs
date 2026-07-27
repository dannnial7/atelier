using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace Atelier
{
    public partial class Portfolio : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        public int CurrentUserId => GetCurrentUserId();

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);
            return 2; // default to Roy
        }

        private static readonly string[] AllowedExt =
            { ".pdf", ".jpg", ".jpeg", ".png", ".mp4", ".zip", ".docx" };
        private const int MaxBytes = 10 * 1024 * 1024; // 10 MB

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
                LoadMine();
                LoadGallery();
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
                    ddlCourse.Items.Clear();
                    ddlCourse.Items.Add(new ListItem("-- Select a course --", ""));
                    while (dr.Read())
                        ddlCourse.Items.Add(new ListItem(dr["Title"].ToString(), dr["CourseID"].ToString()));
                }
            }
        }

        private void LoadMine()
        {
            string sql = @"
                SELECT p.PortfolioID, p.Title, p.FileURL, p.LikeCountT,
                       p.IsFeatured, p.SubmittedAt, c.Title AS CourseTitle
                FROM PortfolioItems p
                JOIN Courses c ON p.CourseID = c.CourseID
                WHERE p.UserID = @UserID
                ORDER BY p.SubmittedAt DESC";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptMine.DataSource = dt;
                    rptMine.DataBind();
                    pnlNoMine.Visible = dt.Rows.Count == 0;
                }
            }
        }

        private void LoadGallery()
        {
            string sql = @"
                SELECT p.PortfolioID, p.Title, p.FileURL, p.LikeCountT,
                       p.IsFeatured, p.SubmittedAt, u.FullName, c.Title AS CourseTitle
                FROM PortfolioItems p
                JOIN Users u ON p.UserID = u.UserID
                JOIN Courses c ON p.CourseID = c.CourseID
                ORDER BY p.IsFeatured DESC, p.SubmittedAt DESC";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptGallery.DataSource = dt;
                rptGallery.DataBind();
                pnlNoGallery.Visible = dt.Rows.Count == 0;
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (!fileUpload.HasFile)
            {
                ShowMessage("Please choose a file.");
                return;
            }

            string ext = Path.GetExtension(fileUpload.FileName).ToLower();
            if (Array.IndexOf(AllowedExt, ext) < 0)
            {
                ShowMessage("File type not allowed. Use PDF, JPEG, PNG, MP4, ZIP, or DOCX.");
                return;
            }
            if (fileUpload.PostedFile.ContentLength > MaxBytes)
            {
                ShowMessage("File is too large (max 10 MB).");
                return;
            }

            string uploadsDir = Server.MapPath("~/Uploads/");
            Directory.CreateDirectory(uploadsDir); // guard
            string fileName = "portfolio_" + CurrentUserId + "_" + DateTime.Now.Ticks + ext;
            fileUpload.SaveAs(Path.Combine(uploadsDir, fileName));
            string relativePath = "~/Uploads/" + fileName;

            string sql = @"INSERT INTO PortfolioItems
                           (UserID, CourseID, Title, Description, FileURL, LikeCountT, IsFeatured, SubmittedAt)
                           VALUES (@UserID, @CourseID, @Title, @Description, @FileURL, 0, 0, GETDATE())";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                cmd.Parameters.AddWithValue("@CourseID", Convert.ToInt32(ddlCourse.SelectedValue));
                cmd.Parameters.AddWithValue("@Title", txtTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                cmd.Parameters.AddWithValue("@FileURL", relativePath);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ddlCourse.SelectedIndex = 0;
            txtTitle.Text = "";
            txtDescription.Text = "";
            ShowMessage("Work uploaded successfully.");
            LoadMine();
            LoadGallery();
        }

        protected void rptMine_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteItem")
            {
                string path = GetFilePath(id);
                if (!string.IsNullOrEmpty(path))
                {
                    string full = Server.MapPath(path);
                    if (File.Exists(full)) File.Delete(full);
                }

                string sql = "DELETE FROM PortfolioItems WHERE PortfolioID = @ID AND UserID = @UserID";
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Item deleted.");
            }
            else if (e.CommandName == "ToggleFeature")
            {
                string sql = @"UPDATE PortfolioItems SET IsFeatured = ~IsFeatured
                               WHERE PortfolioID = @ID AND UserID = @UserID";
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Updated.");
            }

            LoadMine();
            LoadGallery();
        }

        protected void rptGallery_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "LikeItem")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                string sql = "UPDATE PortfolioItems SET LikeCountT = LikeCountT + 1 WHERE PortfolioID = @ID";
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                LoadMine();
                LoadGallery();
            }
        }

        private string GetFilePath(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FileURL FROM PortfolioItems WHERE PortfolioID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                object o = cmd.ExecuteScalar();
                return o?.ToString();
            }
        }

        // Renders an image thumbnail, or a placeholder box for non-images.
        // File type is derived from the file extension since there is no FileType column.
        public string RenderThumb(object fileurl)
        {
            string raw = fileurl?.ToString() ?? "";
            string url = ResolveUrl(raw);
            string ext = Path.GetExtension(raw).TrimStart('.').ToLower();
            if (ext == "jpg" || ext == "jpeg" || ext == "png")
                return "<img class='thumb' src='" + url + "' alt='thumbnail' />";
            return "<div class='filebox'>" + ext.ToUpper() + " file</div>";
        }

        private void ShowMessage(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = true;
        }
    }
}