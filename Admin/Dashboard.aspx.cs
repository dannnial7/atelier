using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        public string EnrolmentChartData { get; set; }
        public string UserChartData { get; set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null) { Response.Redirect("~/Login.aspx"); }
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx"); }
            if (!IsPostBack) { lblAdminName.Text = Session["firstName"].ToString(); 
                LoadStats(); LoadRecentEnrollments(); LoadChartData(); 

        }
    }
        private void LoadStats() { SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString);
            con.Open();
            SqlCommand cmd1 = new SqlCommand("SELECT COUNT(*) FROM Users", con);
            lblTotalUsers.Text = cmd1.ExecuteScalar().ToString();

            SqlCommand cmd2 = new SqlCommand("SELECT COUNT(*) FROM Courses", con);
            lblTotalCourses.Text = cmd2.ExecuteScalar().ToString();

            SqlCommand cmd3 = new SqlCommand("SELECT COUNT(*) FROM Enrollments", con);
            lblTotalEnrollments.Text =cmd3.ExecuteScalar().ToString();

            SqlCommand cmd4 = new SqlCommand("SELECT ISNULL(SUM(Amount), 0) " +
                "FROM Payments", con);
            decimal revenue = Convert.ToDecimal(cmd4.ExecuteScalar());
            lblTotalRevenue.Text ="RM " + revenue.ToString("F2");

            con.Close();
        }

        private void LoadRecentEnrollments()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter( "SELECT TOP 10 U.FullName, C.Title, " +  "E.EnrolledAt, E.Progress " + "FROM Enrollments E " + "JOIN Users U ON E.UserID = U.UserID " +
         "JOIN Courses C ON E.CourseID = C.CourseID " + "ORDER BY E.EnrolledAt DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            rptEnrollments.DataSource = dt;
            rptEnrollments.DataBind();
        }

        private void LoadChartData()
        {
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString);

            con.Open();

            // Enrollments per course for bar chart
            SqlCommand cmd1 = new SqlCommand("SELECT C.Title, COUNT(E.EnrollmentID) " +
                            "AS Total FROM Courses C " +
                            "LEFT JOIN Enrollments E " +
                            "ON C.CourseID = E.CourseID " +
                            "GROUP BY C.Title", con);

            SqlDataReader dr1 = cmd1.ExecuteReader();

            StringBuilder labels1 = new StringBuilder();
            StringBuilder data1 = new StringBuilder();
            labels1.Append("[");
            data1.Append("[");

            bool first = true;
            while (dr1.Read())
            {
                if (!first)
                {
                    labels1.Append(",");
                    data1.Append(",");
                }
                labels1.Append("\"" +
                    dr1[0].ToString() + "\"");
                data1.Append(dr1[1].ToString());
                first = false;
            }
            labels1.Append("]");
            data1.Append("]");
            dr1.Close();

            EnrolmentChartData = "{\"labels\":" + labels1 + ",\"data\":" + data1 + "}";

            // Users by role for doughnut chart
            SqlCommand cmd2 = new SqlCommand( "SELECT Role, COUNT(*) AS Total " + "FROM Users GROUP BY Role", con);

            SqlDataReader dr2 = cmd2.ExecuteReader();

            StringBuilder labels2 = new StringBuilder();
            StringBuilder data2 = new StringBuilder();
            labels2.Append("[");
            data2.Append("[");

            first = true;
            while (dr2.Read())
            {
                if (!first)
                {
                    labels2.Append(",");
                    data2.Append(",");
                }
                labels2.Append("\"" +
                    dr2[0].ToString() + "\"");
                data2.Append(dr2[1].ToString());
                first = false;
            }
            labels2.Append("]");
            data2.Append("]");
            dr2.Close();

            UserChartData ="{\"labels\":" + labels2 + ",\"data\":" + data2 + "}";

            con.Close();
        }
    }
}
        