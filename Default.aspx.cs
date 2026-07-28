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
                LoadFeaturedCourses();
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