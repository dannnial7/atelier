using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            { 
                LoadUserCount(); 
                LoadFeaturedCourses();
            }

        }
        private void LoadUserCount()
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(DISTINCT UserID) FROM Enrollments", con);
                con.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                if (count == 0)
                {
                    SqlCommand cmdUsers = new SqlCommand(
                        "SELECT COUNT(*) FROM USERS WHERE ROLE = 'Learner'", con);
                    count = Convert.ToInt32(cmdUsers.ExecuteScalar());
                }
                lblUserCount.Text = count.ToString();
            }
        }
        private void LoadFeaturedCourses()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString);
            SqlDataAdapter da = new SqlDataAdapter("SELECT TOP 6 C.CourseID, " + "C.Title, C.Thumbnail," + "C.Price, C.Difficulty," + "CC.CategoryName " + "FROM Courses C "
                + "JOIN CourseCategories CC " + "ON C.CategoryID = CC.CategoryID " + "WHERE C.IsPublished = 1" + "ORDER BY C.CreatedAt DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);
            rptCourses.DataSource = dt;
            rptCourses.DataBind();

        }
    }
}