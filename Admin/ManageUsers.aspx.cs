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
    public partial class ManageUsers : System.Web.UI.Page
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
                LoadUsers("", "All");
            }
        }

        private void LoadUsers(string search, string role)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            string query =
                "SELECT UserID, FullName, Email, " +
                "Role, IsActive, RegisteredAt " +
                "FROM Users WHERE 1=1 ";

            if (!string.IsNullOrEmpty(search))
            {
                query += "AND (FullName LIKE '%" +
                    search + "%' " +
                    "OR Email LIKE '%" +
                    search + "%') ";
            }

            if (role != "All")
            {
                query += "AND Role = '" + role + "' ";
            }

            query += "ORDER BY RegisteredAt DESC";

            SqlDataAdapter da =
                new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvUsers.DataSource = dt;
            gvUsers.DataBind();

            lblUserCount.Text =
                dt.Rows.Count.ToString();
        }

                protected void btnSearch_Click(
                    object sender, EventArgs e)
                {
                    LoadUsers(txtSearch.Text.Trim(),
                        ddlRoleFilter.SelectedValue);
                }

                protected void ddlRoleFilter_Changed(
                    object sender, EventArgs e)
                {
                    LoadUsers(txtSearch.Text.Trim(),
                        ddlRoleFilter.SelectedValue);
                }

                protected void btnReset_Click(
                    object sender, EventArgs e)
                {
                    txtSearch.Text = "";
                    ddlRoleFilter.SelectedIndex = 0;
                    LoadUsers("", "All");
                }

        protected void gvUsers_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                string[] args =
                    e.CommandArgument.ToString()
                    .Split(',');
                int userID =
                    Convert.ToInt32(args[0]);
                bool isActive =
                    Convert.ToBoolean(args[1]);

                SqlConnection con =
                    new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand(
                    "UPDATE Users SET IsActive = @status " +
                    "WHERE UserID = @id", con);

                cmd.Parameters.AddWithValue(
                    "@status", isActive ? 0 : 1);
                cmd.Parameters.AddWithValue(
                    "@id", userID);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text = isActive ?
                    "User suspended successfully!" :
                    "User activated successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadUsers(txtSearch.Text.Trim(),
                    ddlRoleFilter.SelectedValue);
            }
            else if (e.CommandName == "DeleteUser")
            {
                int userID =
                    Convert.ToInt32(e.CommandArgument);

                // Prevent admin from deleting themselves
                if (userID.ToString() ==
                    Session["userID"].ToString())
                {
                    lblMessage.Text =
                        "You cannot delete your own account!";
                    lblMessage.CssClass =
                        "alert alert-danger";
                    lblMessage.Visible = true;
                    return;
                }

                SqlConnection con =
                    new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM Users " +
                    "WHERE UserID = @id", con);

                cmd.Parameters.AddWithValue(
                    "@id", userID);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "User deleted successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadUsers(txtSearch.Text.Trim(),
                    ddlRoleFilter.SelectedValue);
            }

        }
            protected void btnShowAdd_Click(
        object sender, EventArgs e)
            {
                txtFullName.Text = "";
                txtEmail.Text = "";
                txtPassword.Text = "";
                ddlRole.SelectedIndex = 0;
                addPanel.Style["display"] = "block";
            }

            protected void btnCancelAdd_Click(
                object sender, EventArgs e)
            {
                addPanel.Style["display"] = "none";
            }

            protected void btnAddUser_Click(
                object sender, EventArgs e)
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand checkCmd = new SqlCommand( "SELECT COUNT(*) FROM Users " +  "WHERE Email = '" + txtEmail.Text + "'", con);
                     con.Open();
                int exists = Convert.ToInt32(
                    checkCmd.ExecuteScalar());

                if (exists > 0)
                {
                    lblMessage.Text =
                        "Email already exists!";
                    lblMessage.CssClass =
                        "alert alert-danger";
                    lblMessage.Visible = true;
                    con.Close();
                    return;
                }

                SqlCommand cmd = new SqlCommand( "INSERT INTO Users " + "(FullName, Email, PasswordHash, " + "Role, IsActive) " +  "VALUES " +  "(@name, @email, @password, " + "@role, 1)", con);
                cmd.Parameters.AddWithValue(
                    "@name", txtFullName.Text);
                cmd.Parameters.AddWithValue(
                    "@email", txtEmail.Text);
                cmd.Parameters.AddWithValue(
                    "@password", txtPassword.Text);
                cmd.Parameters.AddWithValue(
                    "@role", ddlRole.SelectedValue);

                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "User added successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                addPanel.Style["display"] = "none";
                LoadUsers("", "All");
        }
    }
}