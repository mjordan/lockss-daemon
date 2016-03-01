/* $Id$
 
Copyright (c) 2000-2015 Board of Trustees of Leland Stanford Jr. University,
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

package org.lockss.plugin.scielo;

import java.util.*;
import java.util.regex.*;

import org.lockss.daemon.PluginException;
import org.lockss.extractor.ArticleMetadataExtractor;
import org.lockss.extractor.ArticleMetadataExtractorFactory;
import org.lockss.extractor.BaseArticleMetadataExtractor;
import org.lockss.extractor.MetadataTarget;
import org.lockss.plugin.*;
import org.lockss.util.Logger;

public class SciELOArticleIteratorFactory
      implements ArticleIteratorFactory, ArticleMetadataExtractorFactory
{

  private static final Logger log = Logger.getLogger(SciELOArticleIteratorFactory.class);
  

  /*
   * The fulltext URL:
   *  http://www.scielo.br/scielo.php?script=sci_arttext&pid=S0102-67202014000400251&lng=en
   *  http://www.scielo.br/scielo.php?script=sci_arttext&pid=S0102-67202014000400251&lng=en&tlng=pt
   *  
   * The pdf landing page:
   *  http://www.scielo.br/scielo.php?script=sci_pdf&pid=S0102-67202014000400280&lng=..
   *  
   * The pdf URL:
   *  http://www.scielo.br/readcube/epdf.php?doi=10.1590/S0102-6720201PARAM_DEF4000100001&pid=S0102-67202014000100001&pdf_path=abcd/v27n1/0102-6720-abcd-27-01-00001.pdf&lang=en
   *  http://www.scielo.br/pdf/abcd/v27n1/0102-6720-abcd-27-01-00001.pdf
   *       
   */
  protected static final String ROOT_TEMPLATE = "\"%s\", base_url";
  
  // scielo.php?script=sci_arttext&pid=S<journal_issn><year><volume><issue><identifier>&...
  protected static final String PATTERN_TEMPLATE = 
    "\"^%sscielo.php\\?script=sci_arttext&pid=[^&]{0,5}%s%d[0-9]{4,16}&lng=\", base_url, journal_issn, year";

  protected static final List<String> LANGUAGES = Arrays.asList("en", "es", "pt");
  
  protected static final List<Pattern> FULLTEXT_PATTERNS = new ArrayList<Pattern>();

  protected static final List<String> FULLTEXT_REPLACEMENTS = new ArrayList<String>();

  protected static final List<String> ABSTRACT_REPLACEMENTS = new ArrayList<String>();

  protected static final List<String> PDF_LANDING_REPLACEMENTS = new ArrayList<String>();

  static {
    for (String lng : LANGUAGES) {
      FULLTEXT_PATTERNS.add(Pattern.compile("scielo\\.php\\?script=(sci_arttext)&pid=([^&]{0,5}[0-9X-]{9}[0-9]{8,20})&lng=(" + lng + ")()$",
                                            Pattern.CASE_INSENSITIVE));
      FULLTEXT_REPLACEMENTS.add("scielo.php?script=sci_arttext&pid=$1&lng=" + lng);
      ABSTRACT_REPLACEMENTS.add("scielo.php?script=sci_abstract&pid=$1&lng=" + lng);
      PDF_LANDING_REPLACEMENTS.add("scielo.php?script=sci_pdf&pid=$1&lng=" + lng);
    }
    for (String lng : LANGUAGES) {
      for (String tlng : LANGUAGES) {
        FULLTEXT_PATTERNS.add(Pattern.compile("scielo\\.php\\?script=(sci_arttext)&pid=([^&]{0,5}[0-9X-]{9}[0-9]{8,20})&lng=(" + lng + ")&tlng=(" + tlng + ")$",
                                              Pattern.CASE_INSENSITIVE));
        FULLTEXT_REPLACEMENTS.add("scielo.php?script=sci_arttext&pid=$1&lng=" + lng + "&tlng=" + tlng);
        ABSTRACT_REPLACEMENTS.add("scielo.php?script=sci_abstract&pid=$1&lng=" + lng + "&tlng=" + tlng);
      }
    }
  }
  
  // http://www.scielo.br/scieloOrg/php/articleXML.php?pid=S0102-67202014000400233&lang=en
  // Note 'lang' instead of 'lng'
  protected static String XML_REPLACEMENT = "scieloOrg/php/articleXML.php?pid=$1&lang=en";
  
  @Override
  public Iterator<ArticleFiles> createArticleIterator(ArchivalUnit au,
                                                      MetadataTarget target)
                                                          throws PluginException {
    SubTreeArticleIteratorBuilder builder = new SubTreeArticleIteratorBuilder(au)
/*    {
      private SciELOSubTreeArticleIterator local = null;

      @Override
      public SubTreeArticleIterator getSubTreeArticleIterator() {
        // TODO Auto-generated method stub
        super.getSubTreeArticleIterator();
        return local;
      }

      @Override
      protected BuildableSubTreeArticleIterator instantiateBuildableIterator() {
        super.instantiateBuildableIterator();
        local = new SciELOSubTreeArticleIterator(super.au, super.spec);
        return local;
      }
    }*/;
    
    builder.setSpec(target,
                    ROOT_TEMPLATE,
                    PATTERN_TEMPLATE, Pattern.CASE_INSENSITIVE);
    
    builder.addAspect(FULLTEXT_PATTERNS,
                      FULLTEXT_REPLACEMENTS,
                      ArticleFiles.ROLE_FULL_TEXT_HTML);
    
    builder.addAspect(ABSTRACT_REPLACEMENTS,
                      ArticleFiles.ROLE_ABSTRACT);
    
    builder.addAspect(PDF_LANDING_REPLACEMENTS,
                      ArticleFiles.ROLE_FULL_TEXT_PDF_LANDING_PAGE);
    
    builder.addAspect(XML_REPLACEMENT,
                      ArticleFiles.ROLE_FULL_TEXT_XML);
    
//    builder.addAspect(FT_REPLACEMENT2i, ArticleFiles.ROLE_FULL_TEXT_HTML + "_en");
//    builder.addAspect(FT_REPLACEMENT3e, ArticleFiles.ROLE_FULL_TEXT_HTML + "_es");
//    builder.addAspect(FT_REPLACEMENT4p, ArticleFiles.ROLE_FULL_TEXT_HTML + "_pt");
    
//    builder.setFullTextFromRoles(ArticleFiles.ROLE_FULL_TEXT_HTML,
//                                 ArticleFiles.ROLE_FULL_TEXT_PDF);
    
    builder.setRoleFromOtherRoles(ArticleFiles.ROLE_ARTICLE_METADATA,
                                  ArticleFiles.ROLE_ABSTRACT,
                                  ArticleFiles.ROLE_FULL_TEXT_HTML);
    
    return builder.getSubTreeArticleIterator();
  }
  
  // Create Article Metadata Extractor
  @Override
  public ArticleMetadataExtractor createArticleMetadataExtractor(MetadataTarget target)
      throws PluginException {
    return new BaseArticleMetadataExtractor(ArticleFiles.ROLE_ARTICLE_METADATA);
  }

}