<%@ Page Title="Certificate of Completion" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Certificate.aspx.cs" Inherits="Atelier.Certificate" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .certificate-wrapper {
            background: #FAFAFA;
            padding: 40px 20px;
        }
        .certificate {
            background: #FFFFFF;
            border: 12px double #6B1A2A;
            border-radius: 12px;
            padding: 60px 48px;
            text-align: center;
            max-width: 850px;
            margin: 0 auto;
            box-shadow: 0 16px 40px rgba(0,0,0,0.15);
            position: relative;
        }
        .cert-header-icon {
            width: 72px;
            height: 72px;
            margin: 0 auto 16px;
            background: #6B1A2A;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #D4AF37;
        }
        .cert-heading {
            font-family: var(--heading-font, Georgia, serif);
            font-size: 16px;
            letter-spacing: 0.35em;
            text-transform: uppercase;
            color: #6B1A2A;
            font-weight: 700;
        }
        .cert-title {
            font-family: var(--heading-font, Georgia, serif);
            font-size: 34px;
            color: #0f172a;
            margin: 12px 0 24px;
            font-weight: 700;
        }
        .cert-name {
            font-family: var(--heading-font, Georgia, serif);
            font-size: 40px;
            color: #6B1A2A;
            margin: 16px 0 12px;
            border-bottom: 2px solid #D4AF37;
            display: inline-block;
            padding: 0 40px 8px;
            font-weight: 700;
        }
        .cert-course {
            font-family: var(--heading-font, Georgia, serif);
            font-size: 28px;
            color: #1e293b;
            margin: 16px 0;
            font-weight: 600;
        }
        .cert-footer {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            margin-top: 48px;
            padding-top: 24px;
            border-top: 1px solid #e2e8f0;
            font-size: 14px;
            color: #475569;
        }
        .cert-id {
            font-family: monospace;
            letter-spacing: 0.12em;
            font-weight: 700;
            color: #0f172a;
        }
        @media print {
            #navbar, #footer, .no-print, nav, header { display: none !important; }
            body { background: #fff !important; }
            .certificate { border-color: #6B1A2A !important; box-shadow: none !important; margin: 0 !important; width: 100% !important; max-width: 100% !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <%-- Shown when the learner has not yet met the requirements --%>
        <asp:Panel ID="pnlNotEligible" runat="server" Visible="false">
            <div class="alert alert-warning" style="padding:28px;background:#FEF3C7;border:1px solid #FDE68A;border-radius:12px;max-width:700px;margin:0 auto;">
                <h3 style="color:#92400E;margin-top:0;">Certificate Progress Status</h3>
                <p style="color:#B45309;font-size:15px;margin-bottom:16px;">
                    To earn and generate your Certificate of Completion for this course, you must fulfill the following:
                </p>
                <ul style="margin:12px 0 20px 24px;color:#92400E;font-size:15px;line-height:1.8;">
                    <li>
                        <strong>Complete all course modules:</strong>
                        &mdash; <asp:Literal ID="litModuleProgress" runat="server" />
                    </li>
                    <li>
                        <strong>Pass the course quiz assessment:</strong>
                        &mdash; <asp:Literal ID="litAssessmentStatus" runat="server" />
                    </li>
                </ul>
                <asp:HyperLink ID="lnkBackToCourse" runat="server"
                    Text="&larr; Back to Course" CssClass="btn btn-secondary" style="font-weight:600;" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlCertificate" runat="server" Visible="false">

            <div class="certificate-wrapper">
                <div class="certificate">

                    <div class="cert-header-icon">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="8" r="7"></circle>
                            <polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline>
                        </svg>
                    </div>

                    <p class="cert-heading">Official Certification</p>
                    <h2 class="cert-title">Certificate of Completion</h2>

                    <p style="color:#64748b;font-size:16px;">This document certifies that</p>

                    <div class="cert-name"><asp:Literal ID="litLearnerName" runat="server" /></div>

                    <p style="color:#64748b;font-size:16px;margin-top:16px">
                        has successfully completed all required modules and passed the comprehensive assessment for
                    </p>

                    <div class="cert-course"><asp:Literal ID="litCourseTitle" runat="server" /></div>

                    <p class="course-meta" style="font-size:14px;color:#475569;margin-top:12px;">
                        <asp:Literal ID="litCategory" runat="server" />
                        &nbsp;&middot;&nbsp;
                        <asp:Literal ID="litDifficulty" runat="server" /> Level
                        &nbsp;&middot;&nbsp;
                        Assessment Score: <strong><asp:Literal ID="litScore" runat="server" />%</strong>
                    </p>

                    <div class="cert-footer">
                        <div style="text-align:left">
                            <span style="font-size:12px;text-transform:uppercase;letter-spacing:0.05em;color:#94a3b8;">Issue Date</span><br />
                            <strong style="color:#0f172a;"><asp:Literal ID="litCompletedDate" runat="server" /></strong>
                        </div>
                        <div style="text-align:center">
                            <span style="font-family:Georgia, serif;font-style:italic;font-size:18px;color:#6B1A2A;display:block;margin-bottom:2px;">Atelier Academic Board</span>
                            <span style="font-size:12px;text-transform:uppercase;letter-spacing:0.05em;color:#94a3b8;">Verified & Issued By</span>
                        </div>
                        <div style="text-align:right">
                            <span style="font-size:12px;text-transform:uppercase;letter-spacing:0.05em;color:#94a3b8;">Certificate Reference</span><br />
                            <span class="cert-id"><asp:Literal ID="litCertId" runat="server" /></span>
                        </div>
                    </div>

                    <p style="margin-top:40px;font-size:12px;color:#94a3b8;letter-spacing:0.05em;">
                        Atelier &mdash; One Platform. Endless Creativity.
                    </p>
                </div>
            </div>

            <div style="text-align:center;margin-top:28px" class="no-print">
                <button type="button" class="btn btn-primary" onclick="window.print()"
                        style="color:#BFCFE8 !important;background-color:#6B1A2A !important;padding:12px 28px;font-weight:600;margin-right:10px;display:inline-flex;align-items:center;gap:8px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="6 9 6 2 18 2 18 9"></polyline>
                        <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
                        <rect x="6" y="14" width="12" height="8"></rect>
                    </svg>
                    Print / Download PDF
                </button>
                <asp:HyperLink ID="lnkBack" runat="server"
                    Text="Back to Course" CssClass="btn btn-secondary" style="padding:12px 24px;font-weight:600;" />
            </div>

        </asp:Panel>

    </div>

</asp:Content>