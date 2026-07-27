using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class ViewEnrollments : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null)
                Response.Redirect("~/Login.aspx");

            if (Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
                Response.Redirect("~/Login.aspx");

            if (!IsPostBack)
            {
                LoadCourseFilter();
                LoadEnrollments("All", "All");
            }
        }

        private void LoadCourseFilter()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT CourseID, Title FROM Courses ORDER BY Title", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlCourseFilter.DataSource = dt;
            ddlCourseFilter.DataTextField = "Title";
            ddlCourseFilter.DataValueField = "CourseID";
            ddlCourseFilter.DataBind();
            ddlCourseFilter.Items.Insert(0,
                new ListItem("All Courses", "All"));
        }

        private void LoadEnrollments(string courseFilter, string progressFilter)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            string query =
                "SELECT E.EnrollmentID, U.FullName, U.Email, " +
                "C.Title AS CourseTitle, E.EnrolledAt, E.Progress " +
                "FROM Enrollments E " +
                "JOIN Users U ON E.UserID = U.UserID " +
                "JOIN Courses C ON E.CourseID = C.CourseID " +
                "WHERE 1=1 ";

            if (courseFilter != "All")
                query += "AND E.CourseID = " + courseFilter + " ";

            if (progressFilter == "NotStarted")
                query += "AND E.Progress = 0 ";
            else if (progressFilter == "InProgress")
                query += "AND E.Progress > 0 AND E.Progress < 100 ";
            else if (progressFilter == "Completed")
                query += "AND E.Progress = 100 ";

            query += "ORDER BY E.EnrolledAt DESC";

            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvEnrollments.DataSource = dt;
            gvEnrollments.DataBind();

            lblCount.Text = dt.Rows.Count.ToString();
        }

        protected void ddlCourseFilter_Changed(object sender, EventArgs e)
        {
            LoadEnrollments(
                ddlCourseFilter.SelectedValue,
                ddlProgressFilter.SelectedValue);
        }

        protected void ddlProgressFilter_Changed(object sender, EventArgs e)
        {
            LoadEnrollments(
                ddlCourseFilter.SelectedValue,
                ddlProgressFilter.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlCourseFilter.SelectedIndex = 0;
            ddlProgressFilter.SelectedIndex = 0;
            LoadEnrollments("All", "All");
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT U.FullName, U.Email, " +
                "C.Title AS Course, E.EnrolledAt, E.Progress " +
                "FROM Enrollments E " +
                "JOIN Users U ON E.UserID = U.UserID " +
                "JOIN Courses C ON E.CourseID = C.CourseID " +
                "ORDER BY E.EnrolledAt DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            StringBuilder csv = new StringBuilder();
            csv.AppendLine("Full Name,Email,Course,Enrolled Date,Progress");

            foreach (DataRow row in dt.Rows)
            {
                csv.AppendLine(
                    row["FullName"] + "," +
                    row["Email"] + "," +
                    row["Course"] + "," +
                    Convert.ToDateTime(row["EnrolledAt"])
                        .ToString("dd MMM yyyy") + "," +
                    row["Progress"] + "%");
            }

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition",
                "attachment;filename=enrollments.csv");
            Response.Write(csv.ToString());
            Response.End();
        }
    }
}