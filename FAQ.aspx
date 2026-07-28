<%@ Page Title="FAQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FAQ.aspx.cs" Inherits="Atelier.FAQ" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .faq-item {
            border: 0.5px solid var(--border-colour);
            border-radius: var(--radius-md);
            margin-bottom: 12px;
            overflow: hidden;
        }
        .faq-question {
            padding: 16px 20px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-family: var(--heading-font);
            font-size: 15px;
            font-weight: 500;
            color: var(--heading-colour);
            background-color: var(--card-colour);
            transition: background-color 0.2s;
        }
        .faq-question:hover {
            background-color: var(--surface-colour);
        }
        .faq-arrow {
            font-size: 18px;
            transition: transform 0.3s;
            color: var(--muted-colour);
        }
        .faq-item.open .faq-arrow {
            transform: rotate(180deg);
        }
        .faq-answer {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.35s ease, padding 0.35s ease;
            padding: 0 20px;
            font-size: 14px;
            color: var(--text-colour);
            line-height: 1.7;
            background-color: var(--surface-colour);
        }
        .faq-item.open .faq-answer {
            max-height: 500px;
            padding: 16px 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container" style="margin-top:40px">

        <h1>Frequently Asked Questions</h1>
        <p style="color:var(--muted-colour);margin-bottom:32px">
            Find answers to common questions about Atelier.
        </p>

        <asp:Panel ID="pnlNoFAQs" runat="server" Visible="false">
            <div class="alert alert-info">
                No FAQs are available at the moment.
            </div>
        </asp:Panel>

        <div id="faq-list">
            <asp:Repeater ID="rptFAQs" runat="server">
                <ItemTemplate>
                    <div class="faq-item" onclick="toggleFaq(this)">
                        <div class="faq-question">
                            <span><%# Eval("Question") %></span>
                            <svg class="faq-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                        </div>
                        <div class="faq-answer">
                            <%# Eval("Answer") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div style="text-align:center;margin-top:40px;padding:32px;background:var(--surface-colour);border-radius:var(--radius-lg)">
            <h3>Still have questions?</h3>
            <p style="color:var(--muted-colour);margin:12px 0 20px">
                We are here to help. Send us a message and we will get back to you.
            </p>
            <a href="~/Inquiry.aspx" runat="server" class="btn btn-primary">
                Contact Us
            </a>
        </div>

    </div>

    <script type="text/javascript">
        function toggleFaq(item) {
            // Close all other items first (accordion behaviour)
            var allItems = document.querySelectorAll('.faq-item');
            for (var i = 0; i < allItems.length; i++) {
                if (allItems[i] !== item) {
                    allItems[i].classList.remove('open');
                }
            }
            // Toggle the clicked item
            item.classList.toggle('open');
        }
    </script>

</asp:Content>
