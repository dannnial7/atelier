using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class CourseDetail : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        private int CourseId
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (CourseId == 0)
                {
                    pnlCourse.Visible = false;
                    pnlNotFound.Visible = true;
                    return;
                }

                LoadCourse();
                LoadModules();
                LoadProgress();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 2; // TEMPORARY: see Dashboard.aspx.cs
        }

        private void LoadCourse()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT C.Title, C.Description, C.Difficulty, CC.CategoryName " +
                    "FROM Courses C " +
                    "JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "WHERE C.CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    litTitle.Text = dr["Title"].ToString();
                    litDescription.Text = dr["Description"].ToString();
                    litDifficulty.Text = dr["Difficulty"].ToString();
                    litCategory.Text = dr["CategoryName"].ToString();
                }
                else
                {
                    pnlCourse.Visible = false;
                    pnlNotFound.Visible = true;
                }
                dr.Close();
            }
        }

        private void LoadModules()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                // LEFT JOIN so modules the learner has not started still appear,
                // with IsCompleted coming back as 0 rather than no row at all.
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT M.ModuleID, M.Title, M.ContentType, M.DurationMins, M.OrderIndex, " +
                    "ISNULL(MP.IsCompleted, 0) AS IsCompleted " +
                    "FROM Modules M " +
                    "LEFT JOIN ModuleProgress MP " +
                    "  ON M.ModuleID = MP.ModuleID AND MP.UserID = @UserID " +
                    "WHERE M.CourseID = @CourseID " +
                    "ORDER BY M.OrderIndex", con);
                da.SelectCommand.Parameters.AddWithValue("@CourseID", CourseId);
                da.SelectCommand.Parameters.AddWithValue("@UserID", GetCurrentUserId());

                DataTable dt = new DataTable();
                da.Fill(dt);
                rptModules.DataSource = dt;
                rptModules.DataBind();
            }
        }

        private void LoadProgress()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT Progress FROM Enrollments " +
                    "WHERE UserID = @UserID AND CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                object result = cmd.ExecuteScalar();

                if (result != null)
                {
                    int progress = Convert.ToInt32(result);
                    litProgress.Text = progress.ToString();
                    divProgressFill.Style["width"] = progress + "%";
                    pnlProgress.Visible = true;
                }
            }
        }
    }
}