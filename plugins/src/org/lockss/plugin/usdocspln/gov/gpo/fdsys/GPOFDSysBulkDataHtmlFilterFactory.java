/*
 * $Id: GPOFDSysBulkDataHtmlFilterFactory.java,v 1.2 2012-09-27 21:49:49 davidecorcoran Exp $
 */

/*

Copyright (c) 2000-2012 Board of Trustees of Leland Stanford Jr. University,
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

package org.lockss.plugin.usdocspln.gov.gpo.fdsys;

import java.io.*;
import java.util.List;

import org.htmlparser.NodeFilter;
import org.htmlparser.filters.*;
import org.lockss.daemon.PluginException;
import org.lockss.filter.*;
import org.lockss.filter.HtmlTagFilter.TagPair;
import org.lockss.filter.html.*;
import org.lockss.plugin.*;
import org.lockss.util.*;

public class GPOFDSysBulkDataHtmlFilterFactory implements FilterFactory {

  public InputStream createFilteredInputStream(ArchivalUnit au,
                                               InputStream in,
                                               String encoding)
      throws PluginException {
  
    NodeFilter[] filters = new NodeFilter[] {
        new TagNameFilter("script"),
        new TagNameFilter("noscript"),
        
        // Access date
        HtmlNodeFilters.tagWithText("tr", "logRetrievalStats")
    };
  
    OrFilter combinedFilter = new OrFilter(filters);
    HtmlNodeFilterTransform transform = HtmlNodeFilterTransform.exclude(combinedFilter);
    InputStream prefilteredStream = new HtmlFilterInputStream(in, encoding, transform);
        
    List pairs = ListUtil.list(
    // Filter session tokens in comments
    new TagPair("<!--<input type=\"hidden\" name=\"struts.token.name\" value=\"struts.token\" />",
                "\" />-->")
    );
          
    try {
      Reader prefilteredReader = new InputStreamReader(prefilteredStream, encoding);
      Reader filteredReader = HtmlTagFilter.makeNestedFilter(prefilteredReader, pairs);
      Reader whitespaceReader = new WhiteSpaceFilter(filteredReader);
      return new ReaderInputStream(whitespaceReader);
    }
    catch (UnsupportedEncodingException uee) {
      throw new PluginException(uee);
    }
  }  
}