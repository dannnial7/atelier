using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Atelier.Admin
{
    public partial class Announcements : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null)
                Response.Redirect("~/Login.aspx");

            if (Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
                Response.Redirect("~/Login.aspx");

            if (!IsPostBack)
                LoadAnnouncements();
        }

        private void LoadAnnouncements()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
             "SELECT N.NotificationID, N.Title, " +
             "N.Body AS Message, " +
             "N.CreatedAt, " +
             "U.FullName AS PostedBy " +
             "FROM Notifications N " +
             "JOIN Users U ON N.UserID = U.UserID " +
             "WHERE N.Type = 'Announcement' " +
             "ORDER BY N.CreatedAt DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count == 0)
            {
                lblNoAnnouncements.Visible = true;
                rptAnnouncements.Visible = false;
            }
            else
            {
                lblNoAnnouncements.Visible = false;
                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
            }

            lblCount.Text = dt.Rows.Count.ToString();
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlCommand cmd = new SqlCommand(
     "INSERT INTO Notifications " +
     "(UserID, Title, Body, Type, CreatedAt) " +
     "VALUES " +
     "(@sender, @title, @body, 'Announcement', GETDATE())",
     con);

            cmd.Parameters.AddWithValue(
                "@sender", Session["userID"]);
            cmd.Parameters.AddWithValue(
                "@title", txtTitle.Text);
            cmd.Parameters.AddWithValue(
                "@body", txtMessage.Text);

            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            txtTitle.Text = "";
            txtMessage.Text = "";
            ddlTarget.SelectedIndex = 0;

            lblMessage.Text =
                "Announcement posted successfully!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadAnnouncements();
        }

        protected void rptAnnouncements_ItemCommand(
            object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteAnnouncement")
            {
                int notificationID =
                    Convert.ToInt32(e.CommandArgument);

                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM Notifications " +
                    "WHERE NotificationID = " +
                    notificationID, con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Announcement deleted!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadAnnouncements();
            }
        }
    }
}