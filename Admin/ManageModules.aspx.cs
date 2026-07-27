using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class ManageModules : System.Web.UI.Page
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
                LoadCourses();
                LoadModules(0);
            }
        }

        private void LoadCourses()
        {
            SqlConnection con = new SqlConnection( ConfigurationManager  .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter( "SELECT CourseID, Title " + "FROM Courses " + "ORDER BY Title", con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            // Filter dropdown
            ddlFilterCourse.DataSource = dt;
            ddlFilterCourse.DataTextField = "Title";
            ddlFilterCourse.DataValueField = "CourseID";
            ddlFilterCourse.DataBind();
            ddlFilterCourse.Items.Insert(0,
                new ListItem("All Courses", "0"));

            // Form dropdown
            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "Title";
            ddlCourse.DataValueField = "CourseID";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0,
                new ListItem("-- Select Course --", "0"));
        }

        private void LoadModules(int courseID)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            string query =
                "SELECT M.ModuleID, M.Title, " +
                "M.ContentType, M.OrderIndex, " +
                "M.DurationMins, M.IsPreview, " +
                "C.Title AS CourseTitle " +
                "FROM Modules M " +
                "JOIN Courses C " +
                "ON M.CourseID = C.CourseID ";

            if (courseID > 0)
            {
                query += "WHERE M.CourseID = " +
                    courseID + " ";
            }

            query += "ORDER BY C.Title, M.OrderIndex";

            SqlDataAdapter da =
                new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvModules.DataSource = dt;
            gvModules.DataBind();

            lblModuleCount.Text =
                dt.Rows.Count.ToString();
        }

        protected void ddlFilterCourse_Changed(
            object sender, EventArgs e)
        {
            LoadModules(Convert.ToInt32(
                ddlFilterCourse.SelectedValue));
        }

        protected void btnShowAdd_Click(
            object sender, EventArgs e)
        {
            hdnModuleID.Value = "0";
            txtTitle.Text = "";
            txtContentURL.Text = "";
            txtDescription.Text = "";
            txtOrderIndex.Text = "1";
            txtDuration.Text = "0";
            chkIsPreview.Checked = false;
            ddlCourse.SelectedIndex = 0;
            ddlContentType.SelectedIndex = 0;
            lblFormTitle.Text = "Add New Module";
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

            int moduleID = Convert.ToInt32(
                hdnModuleID.Value);

            if (moduleID == 0)
            {
                // INSERT new module
                SqlCommand cmd = new SqlCommand(
                    "INSERT INTO Modules " +
                    "(CourseID, Title, ContentType, " +
                    "ContentURL, Description, " +
                    "OrderIndex, DurationMins, IsPreview) " +
                    "VALUES " +
                    "(@courseID, @title, @type, " +
                    "@url, @desc, @order, @dur, @prev)",
                    con);

                cmd.Parameters.AddWithValue(
                    "@courseID", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@title", txtTitle.Text);
                cmd.Parameters.AddWithValue(
                    "@type", ddlContentType.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@url", txtContentURL.Text);
                cmd.Parameters.AddWithValue(
                    "@desc", txtDescription.Text);
                cmd.Parameters.AddWithValue(
                    "@order", txtOrderIndex.Text);
                cmd.Parameters.AddWithValue(
                    "@dur", txtDuration.Text);
                cmd.Parameters.AddWithValue(
                    "@prev", chkIsPreview.Checked ? 1 : 0);

                cmd.ExecuteNonQuery();

                lblMessage.Text =
                    "Module added successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
            }
            else
            {
                // UPDATE existing module
                SqlCommand cmd = new SqlCommand(
                    "UPDATE Modules SET " +
                    "CourseID = @courseID, " +
                    "Title = @title, " +
                    "ContentType = @type, " +
                    "ContentURL = @url, " +
                    "Description = @desc, " +
                    "OrderIndex = @order, " +
                    "DurationMins = @dur, " +
                    "IsPreview = @prev " +
                    "WHERE ModuleID = @id",
                    con);

                cmd.Parameters.AddWithValue(
                    "@courseID", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@title", txtTitle.Text);
                cmd.Parameters.AddWithValue(
                    "@type", ddlContentType.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@url", txtContentURL.Text);
                cmd.Parameters.AddWithValue(
                    "@desc", txtDescription.Text);
                cmd.Parameters.AddWithValue(
                    "@order", txtOrderIndex.Text);
                cmd.Parameters.AddWithValue(
                    "@dur", txtDuration.Text);
                cmd.Parameters.AddWithValue(
                    "@prev", chkIsPreview.Checked ? 1 : 0);
                cmd.Parameters.AddWithValue(
                    "@id", moduleID);

                cmd.ExecuteNonQuery();

                lblMessage.Text =
                    "Module updated successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
            }

            con.Close();

            formPanel.Style["display"] = "none";
            lblMessage.Visible = true;
            LoadModules(Convert.ToInt32(
                ddlFilterCourse.SelectedValue));
        }

        protected void gvModules_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            int moduleID = Convert.ToInt32(
                e.CommandArgument);

            if (e.CommandName == "EditModule")
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlDataAdapter da =
                    new SqlDataAdapter(
                    "SELECT * FROM Modules " +
                    "WHERE ModuleID = " + moduleID,
                    con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    hdnModuleID.Value =
                        moduleID.ToString();
                    txtTitle.Text =
                        dt.Rows[0]["Title"].ToString();
                    txtContentURL.Text =
                        dt.Rows[0]["ContentURL"]
                        .ToString();
                    txtDescription.Text =
                        dt.Rows[0]["Description"]
                        .ToString();
                    txtOrderIndex.Text =
                        dt.Rows[0]["OrderIndex"]
                        .ToString();
                    txtDuration.Text =
                        dt.Rows[0]["DurationMins"]
                        .ToString();
                    chkIsPreview.Checked =
                        Convert.ToBoolean(
                        dt.Rows[0]["IsPreview"]);
                    ddlContentType.SelectedValue =
                        dt.Rows[0]["ContentType"]
                        .ToString();
                    ddlCourse.SelectedValue =
                        dt.Rows[0]["CourseID"]
                        .ToString();

                    lblFormTitle.Text = "Edit Module";
                    formPanel.Style["display"] = "block";
                }
            }
            else if (e.CommandName == "DeleteModule")
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM Modules " +
                    "WHERE ModuleID = " + moduleID,
                    con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Module deleted successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadModules(Convert.ToInt32(
                    ddlFilterCourse.SelectedValue));
            }

        }
    }
}