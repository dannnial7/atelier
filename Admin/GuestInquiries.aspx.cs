using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Atelier.Admin
{
    public partial class GuestInquiries : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null)
                Response.Redirect("~/Login.aspx");

            if (Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
                Response.Redirect("~/Login.aspx");

            if (!IsPostBack)
                LoadInquiries("Pending");
        }

        private void LoadInquiries(string status)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            string query =
                "SELECT InquiryID, FullName, Email, " +
                "Subject, SubmittedAt, Status " +
                "FROM GuestInquiries ";

            if (status != "All")
                query += "WHERE Status = '" + status + "' ";

            query += "ORDER BY SubmittedAt DESC";

            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvInquiries.DataSource = dt;
            gvInquiries.DataBind();

            lblCount.Text = dt.Rows.Count.ToString();
        }

        protected void btnPending_Click(object sender, EventArgs e)
        {
            LoadInquiries("Pending");
            replyPanel.Style["display"] = "none";
        }

        protected void btnResolved_Click(object sender, EventArgs e)
        {
            LoadInquiries("Resolved");
            replyPanel.Style["display"] = "none";
        }

        protected void btnAll_Click(object sender, EventArgs e)
        {
            LoadInquiries("All");
            replyPanel.Style["display"] = "none";
        }

        protected void gvInquiries_RowCommand(
            object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewInquiry")
            {
                int inquiryID = Convert.ToInt32(e.CommandArgument);
                hdnInquiryID.Value = inquiryID.ToString();

                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT * FROM GuestInquiries " +
                    "WHERE InquiryID = " + inquiryID, con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    lblGuestName.Text = dt.Rows[0]["FullName"].ToString();
                    lblGuestEmail.Text = dt.Rows[0]["Email"].ToString();
                    lblSubject.Text = dt.Rows[0]["Subject"].ToString();
                    lblMessage2.Text = dt.Rows[0]["Message"].ToString();
                    txtResponse.Text = dt.Rows[0]["AdminResponse"].ToString();

                    replyPanel.Style["display"] = "block";
                }
            }
        }

        protected void btnSendReply_Click(object sender, EventArgs e)
        {
            int inquiryID = Convert.ToInt32(hdnInquiryID.Value);

            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlCommand cmd = new SqlCommand( "UPDATE GuestInquiries SET " +  "AdminResponse = @response, " + "Status = 'Resolved' " +  "WHERE InquiryID = @id", con);
            cmd.Parameters.AddWithValue("@response", txtResponse.Text);
            cmd.Parameters.AddWithValue("@id", inquiryID);

            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            lblMessage.Text = "Reply saved and inquiry marked as resolved!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            replyPanel.Style["display"] = "none";
            LoadInquiries("Pending");
        }

        protected void btnCloseReply_Click(object sender, EventArgs e)
        {
            replyPanel.Style["display"] = "none";
        }
    }
}