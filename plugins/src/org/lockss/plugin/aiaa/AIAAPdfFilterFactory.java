/*
 * $Id: AIAAPdfFilterFactory.java,v 1.2 2013-04-30 23:33:09 alexandraohlson Exp $
 */

/*

 Copyright (c) 2000-2013 Board of Trustees of Leland Stanford Jr. University,
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

package org.lockss.plugin.aiaa;

import org.lockss.filter.pdf.ExtractingPdfFilterFactory;
import org.lockss.pdf.PdfDocument;
import org.lockss.pdf.PdfException;
import org.lockss.pdf.PdfUtil;
import org.lockss.plugin.ArchivalUnit;

/*
 * The AIAA pdf files have the CreationDate and ModDate and the two ID numbers in the trailer
 * vary from collection to collection. Filter them out to avoid incorrect hash failures.
 * Because of varying BASEFONT values, must also extract text/images for hash comparison
 */
public class AIAAPdfFilterFactory extends ExtractingPdfFilterFactory {

  public AIAAPdfFilterFactory() {
    super();
  }

  @Override
  public void transform(ArchivalUnit au,
                        PdfDocument pdfDocument)
      throws PdfException {
    pdfDocument.unsetCreationDate();
    pdfDocument.unsetModificationDate();
    PdfUtil.normalizeTrailerId(pdfDocument);
  }

}
