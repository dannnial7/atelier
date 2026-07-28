using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Courses : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
            }
        }

        private void LoadCourses()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT C.CourseID, C.Title, C.Thumbnail, C.Price, C.Difficulty, " +
                    "CC.CategoryName " +
                    "FROM Courses C " +
                    "JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "WHERE C.IsPublished = 1 " +
                    "ORDER BY CASE C.Difficulty " +
                    "  WHEN 'Beginner' THEN 1 " +
                    "  WHEN 'Intermediate' THEN 2 " +
                    "  WHEN 'Advanced' THEN 3 " +
                    "  ELSE 4 END, C.Title ASC", con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptCourses.DataSource = dt;
                rptCourses.DataBind();

                pnlNoCourses.Visible = (dt.Rows.Count == 0);
            }
        }
    }
}
