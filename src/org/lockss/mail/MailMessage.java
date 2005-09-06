/*
 * $Id: MailMessage.java,v 1.2 2005-09-06 20:06:31 tlipkis Exp $
 */

/*

Copyright (c) 2000-2004 Board of Trustees of Leland Stanford Jr. University,
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


package org.lockss.mail;

import java.io.*;
import org.lockss.util.*;
import org.lockss.daemon.*;

/**
 * Interface for messages handled by {@link MailService}
 */
public interface MailMessage  {
  /** Add a header to the message */
  public MailMessage addHeader(String name, String val);

  /** Send the body, ensuring proper network end-of-line, quoting any
   * leading dots, and terminating with <nl>,<nl>
   */
  void sendBody(PrintStream ostrm) throws IOException;

  /** Called just before message is discarded, to give message a chance to
   * deleted any temporary files, etc.
   */
  void delete(boolean sentOk);
}
