using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace Atelier.Admin
{
    public partial class Analytics : System.Web.UI.Page
    {
        public string CourseChartData { get; set; }
        public string RoleChartData { get; set; }
        public string ProgressChartData { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null)
                Response.Redirect("~/Login.aspx");

            if (Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
                Response.Redirect("~/Login.aspx");

            if (!IsPostBack)
            {
                LoadStats();
                LoadCharts();
                LoadTopLearners();
            }
        }

        private void LoadStats()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            con.Open();

            SqlCommand cmd1 = new SqlCommand( "SELECT COUNT(*) FROM Users " + "WHERE Role = 'Learner'", con);
            lblTotalUsers.Text =
                cmd1.ExecuteScalar().ToString();

            SqlCommand cmd2 = new SqlCommand( "SELECT COUNT(*) FROM Enrollments", con);
            lblTotalEnrollments.Text =
                cmd2.ExecuteScalar().ToString();

            SqlCommand cmd3 = new SqlCommand(  "SELECT COUNT(*) FROM Enrollments " +  "WHERE Progress = 100", con);
            int completed = Convert.ToInt32(
                cmd3.ExecuteScalar());

            SqlCommand cmd4 = new SqlCommand( "SELECT COUNT(*) FROM Enrollments", con);
            int total = Convert.ToInt32(
                cmd4.ExecuteScalar());

            if (total > 0)
                lblCompletionRate.Text =
                    Math.Round((double)completed /
                    total * 100, 1) + "%";
            else
                lblCompletionRate.Text = "0%";

            SqlCommand cmd5 = new SqlCommand(
                "SELECT ISNULL(SUM(Amount), 0) " +
                "FROM Payments", con);
            decimal revenue = Convert.ToDecimal(
                cmd5.ExecuteScalar());
            lblTotalRevenue.Text =
                "RM " + revenue.ToString("F2");

            con.Close();
        }

        private void LoadCharts()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            con.Open();

            SqlCommand cmd1 = new SqlCommand(
                "SELECT C.Title, COUNT(E.EnrollmentID) " +
                "AS Total FROM Courses C " +
                "LEFT JOIN Enrollments E " +
                "ON C.CourseID = E.CourseID " +
                "GROUP BY C.Title " +
                "ORDER BY Total DESC", con);

            SqlDataReader dr1 = cmd1.ExecuteReader();
            StringBuilder l1 = new StringBuilder("[");
            StringBuilder d1 = new StringBuilder("[");
            bool first = true;

            while (dr1.Read())
            {
                if (!first) { l1.Append(","); d1.Append(","); }
                l1.Append("\"" + dr1[0].ToString() + "\"");
                d1.Append(dr1[1].ToString());
                first = false;
            }
            l1.Append("]"); d1.Append("]");
            dr1.Close();

            CourseChartData =
                "{\"labels\":" + l1 + ",\"data\":" + d1 + "}";

            SqlCommand cmd2 = new SqlCommand(
                "SELECT Role, COUNT(*) FROM Users " +
                "GROUP BY Role", con);

            SqlDataReader dr2 = cmd2.ExecuteReader();
            StringBuilder l2 = new StringBuilder("[");
            StringBuilder d2 = new StringBuilder("[");
            first = true;

            while (dr2.Read())
            {
                if (!first) { l2.Append(","); d2.Append(","); }
                l2.Append("\"" + dr2[0].ToString() + "\"");
                d2.Append(dr2[1].ToString());
                first = false;
            }
            l2.Append("]"); d2.Append("]");
            dr2.Close();

            RoleChartData =
                "{\"labels\":" + l2 + ",\"data\":" + d2 + "}";

            SqlCommand cmd3 = new SqlCommand(
                "SELECT C.Title, " +
                "ISNULL(AVG(CAST(E.Progress AS FLOAT)), 0) " +
                "AS AvgProgress FROM Courses C " +
                "LEFT JOIN Enrollments E " +
                "ON C.CourseID = E.CourseID " +
                "GROUP BY C.Title " +
                "ORDER BY AvgProgress DESC", con);

            SqlDataReader dr3 = cmd3.ExecuteReader();
            StringBuilder l3 = new StringBuilder("[");
            StringBuilder d3 = new StringBuilder("[");
            first = true;

            while (dr3.Read())
            {
                if (!first) { l3.Append(","); d3.Append(","); }
                l3.Append("\"" + dr3[0].ToString() + "\"");
                d3.Append(Math.Round(
                    Convert.ToDouble(dr3[1]), 1).ToString());
                first = false;
            }
            l3.Append("]"); d3.Append("]");
            dr3.Close();

            ProgressChartData =
                "{\"labels\":" + l3 + ",\"data\":" + d3 + "}";

            con.Close();
        }

        private void LoadTopLearners()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT TOP 10 U.FullName, U.Email, " +
                "COUNT(E.EnrollmentID) AS CoursesEnrolled, " +
                "SUM(CASE WHEN E.Progress = 100 " +
                "THEN 1 ELSE 0 END) AS CoursesCompleted, " +
                "CAST(ISNULL(AVG(CAST(E.Progress AS FLOAT)),0) " +
                "AS VARCHAR) + '%' AS AvgProgress " +
                "FROM Users U " +
                "LEFT JOIN Enrollments E " +
                "ON U.UserID = E.UserID " +
                "WHERE U.Role = 'Learner' " +
                "GROUP BY U.UserID, U.FullName, U.Email " +
                "ORDER BY CoursesCompleted DESC, " +
                "CoursesEnrolled DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvTopLearners.DataSource = dt;
            gvTopLearners.DataBind();
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT C.Title AS Course, " +
                "COUNT(E.EnrollmentID) AS Enrollments, " +
                "SUM(CASE WHEN E.Progress = 100 " +
                "THEN 1 ELSE 0 END) AS Completions, " +
                "CAST(ISNULL(AVG(CAST(E.Progress AS FLOAT)),0) " +
                "AS DECIMAL(5,1)) AS AvgProgress " +
                "FROM Courses C " +
                "LEFT JOIN Enrollments E " +
                "ON C.CourseID = E.CourseID " +
                "GROUP BY C.Title " +
                "ORDER BY Enrollments DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            StringBuilder csv = new StringBuilder();
            csv.AppendLine(
                "Course,Enrollments,Completions,Avg Progress");

            foreach (DataRow row in dt.Rows)
            {
                csv.AppendLine(
                    row["Course"] + "," +
                    row["Enrollments"] + "," +
                    row["Completions"] + "," +
                    row["AvgProgress"] + "%");
            }

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition",
                "attachment;filename=analytics-report.csv");
            Response.Write(csv.ToString());
            Response.End();
        }
    }
}