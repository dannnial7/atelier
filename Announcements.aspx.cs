using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Announcements : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAnnouncements();
            }
        }

        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT N.NotificationID, N.Title, N.Body, N.CreatedAt,
                       ISNULL(U.FullName, 'Atelier Team') AS PostedBy
                FROM Notifications N
                LEFT JOIN Users U ON N.UserID = U.UserID
                WHERE N.Type = 'Announcement'
                ORDER BY N.CreatedAt DESC";

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptAnnouncements.DataSource = dt;
                    rptAnnouncements.DataBind();
                    rptAnnouncements.Visible = true;
                    pnlEmpty.Visible = false;
                }
                else
                {
                    rptAnnouncements.Visible = false;
                    pnlEmpty.Visible = true;
                }
            }
        }
    }
}
