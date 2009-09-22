/*
 * $Id: HighWireHtmlFilterFactory.java,v 1.5 2009-09-22 01:27:36 thib_gc Exp $
 */

/*

Copyright (c) 2000-2009 Board of Trustees of Leland Stanford Jr. University,
all rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
STANFORD UNIVERSITY BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of Stanford University shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from Stanford University.

*/

package org.lockss.plugin.highwire;

import java.io.*;

import org.htmlparser.NodeFilter;
import org.htmlparser.filters.*;
import org.lockss.util.*;
import org.lockss.filter.*;
import org.lockss.filter.html.*;
import org.lockss.plugin.*;

public class HighWireHtmlFilterFactory implements FilterFactory {
  // Use the logic in HighWireFilterRule.  That class should be retired in
  // favor of this one once all running daemons support FilterFactory, at
  // which point the filter logic should be moved here.
  public InputStream createFilteredInputStream(ArchivalUnit au,
					       InputStream in,
					       String encoding) {
    NodeFilter[] filters = new NodeFilter[] {
        // Contains variable ad-generating code
        new TagNameFilter("script"),
        // Contains variable ad-generating code
        new TagNameFilter("noscript"),
        // Typically contains ads (e.g. American Academy of Pediatrics)
        new TagNameFilter("object"),
        // Typically contains ads 
        new TagNameFilter("iframe"),
        // Contains ads (e.g. American Medical Association)
        HtmlNodeFilters.tagWithAttribute("div", "id", "advertisement"),
        HtmlNodeFilters.tagWithAttribute("div", "id", "authenticationstring"),
        // Contains institution name (e.g. SAGE Publications)
        HtmlNodeFilters.tagWithAttribute("div", "id", "universityarea"),
        // Contains institution name (e.g. Oxford University Press)
        HtmlNodeFilters.tagWithAttribute("div", "id", "inst_logo"),
        // Contains institution name (e.g. American Medical Association)
        HtmlNodeFilters.tagWithAttribute("p", "id", "UserToolbar"),
        HtmlNodeFilters.tagWithAttribute("div", "id", "user_nav"),
        HtmlNodeFilters.tagWithAttribute("table", "class", "content_box_inner_table"),
        HtmlNodeFilters.tagWithAttribute("a", "class", "contentbox"),
        HtmlNodeFilters.tagWithAttribute("div", "id", "ArchivesNav"),
        HtmlNodeFilters.tagWithText("strong", "related", true),
        HtmlNodeFilters.lowestLevelMatchFilter(HtmlNodeFilters.tagWithText("table", "Related Content", false)),
        // Contains the current year (e.g. Oxford University Press)
        HtmlNodeFilters.tagWithAttribute("div", "id", "copyright"),
        // Contains the current year (e.g. SAGE Publications)
        HtmlNodeFilters.tagWithAttribute("div", "id", "footer"),
        // Contains the current date and time (e.g. American Medical Association)
        HtmlNodeFilters.tagWithAttribute("a", "target", "help"),
        // Contains the name and date of the current issue (e.g. Oxford University Press)
        HtmlNodeFilters.tagWithAttribute("li", "id", "nav_current_issue"),
        // Contains ads or variable banners (e.g. Oxford University Press)
        HtmlNodeFilters.tagWithAttribute("div", "id", "oas_top"),
        // Contains ads or variable banners (e.g. Oxford University Press)
        HtmlNodeFilters.tagWithAttribute("div", "id", "oas_bottom"),
        // Optional institution-specific citation resolver (e.g. SAGE Publications)
        HtmlNodeFilters.tagWithAttributeRegex("a", "href", "^/cgi/openurl"),
        // Contains ad-dependent URLs (e.g. American Academy of Pediatrics)
        HtmlNodeFilters.tagWithAttributeRegex("a", "href", "^http://ads.adhostingsolutions.com/"),
    };


    // First filter with HtmlParser
    OrFilter orFilter = new OrFilter(filters);
    InputStream filtered = new HtmlFilterInputStream(in,
                                                     encoding,
                                                     HtmlNodeFilterTransform.exclude(orFilter));

    // Then filter with HighWireFilterRule
    Reader reader = FilterUtil.getReader(filtered, encoding);
    Reader filtReader = HighWireFilterRule.makeFilteredReader(reader);
    return new ReaderInputStream(filtReader);
  }

}

