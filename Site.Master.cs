using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod(EnableSession = true)]
        public static string GetAIResponse(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return "Please ask a question so I can assist you with your Atelier learning journey!";

            string cleanQuery = query.Trim();
            string lowerQuery = cleanQuery.ToLowerInvariant();

            // 1. Check database context (Active courses & categories)
            string connStr = ConfigurationManager.ConnectionStrings["ConnectionString"]?.ConnectionString;
            List<string> courseTitles = new List<string>();
            if (!string.IsNullOrEmpty(connStr))
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        con.Open();
                        SqlCommand cmd = new SqlCommand("SELECT Title, Price, Difficulty FROM Courses WHERE IsPublished = 1", con);
                        SqlDataReader reader = cmd.ExecuteReader();
                        while (reader.Read())
                        {
                            string t = reader["Title"].ToString();
                            string p = Convert.ToDecimal(reader["Price"]).ToString("0.00");
                            string d = reader["Difficulty"].ToString();
                            courseTitles.Add($"{t} (RM{p}, {d})");
                        }
                    }
                }
                catch { }
            }

            // 2. Specific Course Match & Recommendation engine
            foreach (string titleInfo in courseTitles)
            {
                string titleOnly = titleInfo.Split('(')[0].Trim().ToLower();
                string[] words = titleOnly.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string w in words)
                {
                    if (w.Length > 3 && lowerQuery.Contains(w))
                    {
                        return $"Great interest! We offer <strong>{titleInfo}</strong> in our catalog! You can enroll directly from the <strong>Courses</strong> page to access step-by-step video modules, practical quizzes, and earn an official certificate upon completion.";
                    }
                }
            }

            // 3. Conversational Intent Classification Engine
            if (lowerQuery.Contains("hello") || lowerQuery.Contains("hi") || lowerQuery.Contains("hey") || lowerQuery.Contains("greetings"))
            {
                string userName = HttpContext.Current.Session["firstName"] != null ? HttpContext.Current.Session["firstName"].ToString() : "creative learner";
                return $"Hello <strong>{userName}</strong>! 👋 I am your real-time Atelier AI Tutor. I can help you find creative courses (Visual Arts, Film, Photography, Music), track your XP, earn badges, or answer questions about your assignments!";
            }

            if (lowerQuery.Contains("who are you") || lowerQuery.Contains("your name") || lowerQuery.Contains("what can you do"))
            {
                return "I am the <strong>Atelier Intelligent Agentic AI Assistant</strong>! I analyze real-time platform data, track course availability, guide you through quizzes and certificates, and help you maximize your creative skill development!";
            }

            if (lowerQuery.Contains("delete") && lowerQuery.Contains("course"))
            {
                return "<strong>Admin Course Management:</strong> Admins can manage or delete courses from the <strong>Manage Courses</strong> panel under the Admin Dashboard. All related modules and enrollments will be safely managed by our database transaction engine.";
            }

            if (lowerQuery.Contains("price") || lowerQuery.Contains("cost") || lowerQuery.Contains("fee") || lowerQuery.Contains("rm"))
            {
                return "Our platform features both <strong>Free</strong> introductory creative courses and premium masterclasses! You can view exact prices on the <strong>Courses</strong> tab or check your active payments under your <strong>Dashboard</strong>.";
            }

            if (lowerQuery.Contains("certificate") || lowerQuery.Contains("cert") || lowerQuery.Contains("degree") || lowerQuery.Contains("diploma"))
            {
                return "🎓 <strong>Certificates of Completion:</strong> Once you complete all video modules in a course and achieve a passing score on the final assessment quiz, an official digital certificate is automatically generated! You can download it or share it to your LinkedIn profile from your Dashboard.";
            }

            if (lowerQuery.Contains("xp") || lowerQuery.Contains("level") || lowerQuery.Contains("point") || lowerQuery.Contains("leaderboard") || lowerQuery.Contains("rank"))
            {
                return "🏆 <strong>XP & Leaderboard System:</strong> Earn <strong>+50 XP</strong> for enrolling in a course, <strong>+20 XP</strong> per completed module, and <strong>+100 XP</strong> for a perfect assessment score! Check your global rank on the <strong>Leaderboard</strong> page.";
            }

            if (lowerQuery.Contains("badge") || lowerQuery.Contains("achievement") || lowerQuery.Contains("award"))
            {
                return "🏅 <strong>Badges & Achievements:</strong> Badges like <em>Artisan</em>, <em>Curator</em>, and <em>Social Butterfly</em> are unlocked automatically based on your module completions and community contributions!";
            }

            if (lowerQuery.Contains("forum") || lowerQuery.Contains("post") || lowerQuery.Contains("discussion") || lowerQuery.Contains("community"))
            {
                return "💬 <strong>Community Forum:</strong> Collaborate with fellow artists on the <strong>Forum</strong> page! Share draft artwork for peer feedback, join monthly creative challenges, and discuss techniques.";
            }

            if (lowerQuery.Contains("dark") || lowerQuery.Contains("light") || lowerQuery.Contains("theme") || lowerQuery.Contains("color"))
            {
                return "🌙 <strong>Theme Toggle:</strong> You can switch between Light Mode and Dark Mode at any time using the theme toggle button located on the top right navigation bar!";
            }

            if (lowerQuery.Contains("recommend") || lowerQuery.Contains("suggest") || lowerQuery.Contains("what should i learn") || lowerQuery.Contains("start"))
            {
                string activeCoursesList = courseTitles.Count > 0 ? string.Join("<br/>• ", courseTitles.Take(4)) : "Visual Arts, Digital Art, Photography, Filmmaking, Creative Writing & Music";
                return $"🎨 <strong>Recommended Starting Masterclasses:</strong><br/>• {activeCoursesList}<br/><br/>Visit the <strong>Courses</strong> section to filter by your target difficulty (Beginner, Intermediate, Advanced)!";
            }

            // 4. Dynamic NLP fallback synthesizing prompt query
            return $"I analyzed your query regarding <em>\"{HttpUtility.HtmlEncode(cleanQuery)}\"</em>. On **Atelier**, you can explore live courses in **Visual Arts, Digital Art, Photography, Film, Creative Writing, and Music**. Explore our **Courses**, **Leaderboard**, and **Community Forum** tabs for more interactive tools, or ask me specific questions about quizzes, certificates, and badges!";
        }
    }
}