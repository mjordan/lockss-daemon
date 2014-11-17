/*
 * $Id: TestPublisher.java,v 1.2 2014-11-17 22:29:04 thib_gc Exp $
 */

/*

Copyright (c) 2000-2014 Board of Trustees of Leland Stanford Jr. University,
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

package org.lockss.tdb;

import java.util.*;

import org.lockss.test.LockssTestCase;

public class TestPublisher extends LockssTestCase {

  public static final String NAME_VALUE = "Publisher Name";

  public static final String FOO_KEY = "publisherfookey";
  public static final String FOO_VALUE = "publisherfooval";

  public void testKeys() throws Exception {
    assertEquals("name", Publisher.NAME);
  }
  
  public void testEmpty() throws Exception {
    Publisher publisher = new Publisher();
    assertNull(publisher.getName());
    assertNull(publisher.getArbitraryValue(FOO_KEY));
  }
  
  public void testPublisher() throws Exception {
    Map<String, String> map = new HashMap<String, String>();
    Publisher publisher = new Publisher(map);
    map.put(Publisher.NAME, NAME_VALUE);
    assertEquals(NAME_VALUE, publisher.getName());
    map.put(FOO_KEY, FOO_VALUE);
    assertEquals(FOO_VALUE, publisher.getArbitraryValue(FOO_KEY));
    assertNull(publisher.getArbitraryValue("X" + FOO_KEY));
  }
  
}
