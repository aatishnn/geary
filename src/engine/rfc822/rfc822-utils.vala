/* Copyright 2011-2012 Yorba Foundation
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution. 
 */

namespace Geary.RFC822.Utils {

/**
 * Returns a quoted text string needed for a reply.
 *
 * If there's no message body in the supplied email, this function will
 * return the empty string.
 *
 * TODO: Support HTML as an option.
 */
public string quote_email_for_reply(Geary.Email email) {
    if (email.body == null)
        return "";
    
    string quoted = "";
    
    if (email.date != null)
        quoted += _("On %s, ").printf(email.date.value.format(_("%a, %b %-e, %Y at %-l:%M %p")));
    
    if (email.from != null)
        quoted += _("%s wrote:").printf(email.from.to_string());
    
    if (email.body != null)
        quoted += "\n" + quote_body(email);
    
    return quoted;
}

/**
 * Returns a quoted text string needed for a forward.
 *
 * If there's no message body in the supplied email, this function will
 * return the empty string.
 *
 * TODO: Support HTML as an option.
 */
public string quote_email_for_forward(Geary.Email email) {
    if (email.body == null)
        return "";
    
    string quoted = "";
    
    quoted += _("---------- Forwarded message ----------");
    quoted += "\n\n";
    quoted += _("From: %s\n").printf(email.from != null ? email.from.to_string() : "");
    quoted += _("Subject %s\n").printf(email.subject != null ? email.subject.to_string() : "");
    quoted += _("Date: %s\n").printf(email.date != null ? email.date.to_string() : "");
    quoted += _("To: %s\n").printf(email.to != null ? email.to.to_string() : "");
    
    if (email.body != null)
        quoted += "\n" + quote_body(email, false);
    
    return quoted;
}

private string quote_body(Geary.Email email, bool line_start_char = true) {
    string body_text = "";
    try {
        body_text = email.get_message().get_first_mime_part_of_content_type("text/plain").to_utf8();
    } catch (Error err) {
        try {
            body_text = Geary.HTML.remove_html_tags(email.get_message().
                get_first_mime_part_of_content_type("text/html").to_utf8());
        } catch (Error err2) {
            debug("Could not get message text. %s", err2.message);
        }
    }
    
    string ret = "";
    string[] lines = body_text.split("\n");
    for (int i = 0; i < lines.length; i++) {
        if (line_start_char)
            ret += "> ";
        
        ret += lines[i];
    }
    
    return ret;
}

}

