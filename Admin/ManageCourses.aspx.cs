using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class ManageCourses : System.Web.UI.Page
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
                LoadCategories();
                LoadCourses();
            }
        }

            private void LoadCategories()
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT CategoryID, CategoryName " +
                    "FROM CourseCategories " +
                    "ORDER BY CategoryName", con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlCategory.DataSource = dt;
                ddlCategory.DataTextField = "CategoryName";
                ddlCategory.DataValueField = "CategoryID";
                ddlCategory.DataBind();

                ddlCategory.Items.Insert(0,
                    new ListItem("-- Select Category --", "0"));
            }

        private void LoadCourses()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter("SELECT C.CourseID, C.Title, " +  "C.Price, C.Difficulty, " +   "C.IsPublished, C.Thumbnail, " +  "CC.CategoryName, " +  "(SELECT COUNT(*) FROM Enrollments E " +
    "WHERE E.CourseID = C.CourseID) " +  "AS EnrollmentCount " +   "FROM Courses C " +   "JOIN CourseCategories CC " +   "ON C.CategoryID = CC.CategoryID " +    "ORDER BY C.CourseID DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvCourses.DataSource = dt;
            gvCourses.DataBind();

            lblCourseCount.Text =
                dt.Rows.Count.ToString();
        }

            protected void btnShowAdd_Click(
                object sender, EventArgs e)
            {
                hdnCourseID.Value = "0";
                txtTitle.Text = "";
                txtDescription.Text = "";
                txtPrice.Text = "0.00";
                txtThumbnail.Text = "";
                chkPublished.Checked = true;
                ddlDifficulty.SelectedIndex = 0;
                lblFormTitle.Text = "Add New Course";

                formPanel.Style["display"] = "block";
            }

        protected void btnCancel_Click(
            object sender, EventArgs e)
        {
            formPanel.Style["display"] = "none";
            lblMessage.Visible = false;
        }

        protected void btnSave_Click(
            object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            con.Open();

            int courseID =
                Convert.ToInt32(hdnCourseID.Value);

            if (courseID == 0)
            {

                SqlCommand cmd = new SqlCommand( "INSERT INTO Courses " + "(Title, Description, CategoryID, " + "Price, Difficulty, IsPublished, " +
                    "CreatedBy, Thumbnail) " +  "VALUES " + "(@title, @desc, @catID, " +  "@price, @diff, @pub, @by, @thumb)", con);

                    cmd.Parameters.AddWithValue(
                        "@title", txtTitle.Text);
                    cmd.Parameters.AddWithValue(
                        "@desc", txtDescription.Text);
                    cmd.Parameters.AddWithValue(
                        "@catID", ddlCategory.SelectedValue);
                    cmd.Parameters.AddWithValue(
                        "@price", txtPrice.Text);
                    cmd.Parameters.AddWithValue(
                        "@diff", ddlDifficulty.SelectedValue);
                    cmd.Parameters.AddWithValue(
                        "@pub", chkPublished.Checked ? 1 : 0);
                    cmd.Parameters.AddWithValue(
                        "@by", Session["userID"]);
                    cmd.Parameters.AddWithValue(
                        "@thumb", txtThumbnail.Text);

                    cmd.ExecuteNonQuery();

                    lblMessage.Text =
                        "Course added successfully!";
                    lblMessage.CssClass =
                        "alert alert-success";
            }
            else
            {
                SqlCommand cmd = new SqlCommand( "UPDATE Courses SET " + "Title = @title, " +  "Description = @desc, " +  "CategoryID = @catID, " + "Price = @price, " +
                    "Difficulty = @diff, " + "IsPublished = @pub, " +  "Thumbnail = @thumb " +  "WHERE CourseID = @id", con);

                cmd.Parameters.AddWithValue(
                    "@title", txtTitle.Text);
                cmd.Parameters.AddWithValue(
                    "@desc", txtDescription.Text);
                cmd.Parameters.AddWithValue(
                    "@catID", ddlCategory.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@price", txtPrice.Text);
                cmd.Parameters.AddWithValue(
                    "@diff", ddlDifficulty.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@pub", chkPublished.Checked ? 1 : 0);
                cmd.Parameters.AddWithValue(
                    "@thumb", txtThumbnail.Text);
                cmd.Parameters.AddWithValue(
                    "@id", courseID);

                cmd.ExecuteNonQuery();

                lblMessage.Text =
                    "Course updated successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
            }

            con.Close();

            formPanel.Style["display"] = "none";
            lblMessage.Visible = true;
            LoadCourses();
        }

        protected void gvCourses_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            int courseID =
                Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditCourse")
            {
                // Load course data into form
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlDataAdapter da =
                    new SqlDataAdapter(
                    "SELECT * FROM Courses " +
                    "WHERE CourseID = " + courseID,
                    con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    hdnCourseID.Value =
                        courseID.ToString();
                    txtTitle.Text =
                        dt.Rows[0]["Title"].ToString();
                    txtDescription.Text =
                        dt.Rows[0]["Description"]
                        .ToString();
                    txtPrice.Text =
                        dt.Rows[0]["Price"].ToString();
                    txtThumbnail.Text =
                        dt.Rows[0]["Thumbnail"]
                        .ToString();
                    chkPublished.Checked =
                        Convert.ToBoolean(
                        dt.Rows[0]["IsPublished"]);
                    ddlDifficulty.SelectedValue =
                        dt.Rows[0]["Difficulty"]
                        .ToString();
                    ddlCategory.SelectedValue =
                        dt.Rows[0]["CategoryID"]
                        .ToString();

                    lblFormTitle.Text =
                        "Edit Course";
                    formPanel.Style["display"] =
                        "block";
                }
            }
            else if (e.CommandName == "DeleteCourse")
            {
         
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand( "DELETE FROM Courses " +  "WHERE CourseID = " + courseID,  con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Course deleted successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadCourses();
            }

        }
    }
}