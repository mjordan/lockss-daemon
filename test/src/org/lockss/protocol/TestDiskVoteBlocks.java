package org.lockss.protocol;

import java.io.*;
import java.util.*;

import org.lockss.test.*;


public class TestDiskVoteBlocks extends LockssTestCase {

  File tempDir;
  
  protected void setUp() throws Exception {
    super.setUp();
    tempDir = this.getTempDir();
  }

  protected void tearDown() throws Exception {
    super.tearDown();
  }

  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.DiskVoteBlocks(int, InputStream, File)'
   */
  public void testDiskVoteBlocks() throws Exception {
//  Construct a byte array in memory to read in.
    int blockCount = 20;
    
    List voteBlockList = V3TestUtils.makeVoteBlockList(blockCount);

    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    DataOutputStream dos = new DataOutputStream(bos);
    
    for (Iterator iter = voteBlockList.iterator(); iter.hasNext(); ) {
      VoteBlock vb = (VoteBlock)iter.next();
      dos.write(vb.getEncoded());
    }
    
    byte[] encodedBlocks = bos.toByteArray();
    ByteArrayInputStream bis = new ByteArrayInputStream(encodedBlocks);

    DiskVoteBlocks dvb = new DiskVoteBlocks(blockCount, bis, tempDir);
    
    assertEquals(dvb.size(), blockCount);
  }
  
  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.addVoteBlock(VoteBlock)'
   */
  public void testAddVoteBlock() throws Exception {
    DiskVoteBlocks dvb = new DiskVoteBlocks(tempDir);
    assertEquals(0, dvb.size());

    List voteBlockList = V3TestUtils.makeVoteBlockList(3);
    
    // Add first block.
    dvb.addVoteBlock((VoteBlock)voteBlockList.get(0));
    assertEquals(1, dvb.size());
    assertEquals((VoteBlock)voteBlockList.get(0), dvb.getVoteBlock(0));
    
    dvb.addVoteBlock((VoteBlock)voteBlockList.get(1));
    assertEquals(2, dvb.size());
    assertEquals((VoteBlock)voteBlockList.get(1), dvb.getVoteBlock(1));
    
    dvb.addVoteBlock((VoteBlock)voteBlockList.get(2));
    assertEquals(3, dvb.size());
    assertEquals((VoteBlock)voteBlockList.get(2), dvb.getVoteBlock(2));
  }

  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.listIterator()'
   */
  public void testListIterator() throws Exception {
    
    List voteBlockList = V3TestUtils.makeVoteBlockList(3);
    
    DiskVoteBlocks dvb = makeDiskVoteBlocks(voteBlockList);
    
    ListIterator iter = dvb.listIterator();
    
    // First
    assertTrue(iter.hasNext());
    assertFalse(iter.hasPrevious());
    assertEquals(0, iter.nextIndex());
    assertEquals(-1, iter.previousIndex());
    VoteBlock vb0 = (VoteBlock)iter.next();
    assertNotNull(vb0);
    assertEquals(vb0, (VoteBlock)voteBlockList.get(0));
    
    // Second
    assertTrue(iter.hasNext());
    assertTrue(iter.hasPrevious());
    assertEquals(1, iter.nextIndex());
    assertEquals(0, iter.previousIndex());
    VoteBlock vb1 = (VoteBlock)iter.next();
    assertNotNull(vb1);
    assertEquals(vb1, (VoteBlock)voteBlockList.get(1));
    
    // Third
    assertTrue(iter.hasNext());
    assertTrue(iter.hasPrevious());
    assertEquals(2, iter.nextIndex());
    assertEquals(1, iter.previousIndex());
    VoteBlock vb2 = (VoteBlock)iter.next();
    assertNotNull(vb2);
    assertEquals(vb2, (VoteBlock)voteBlockList.get(2));
    
    // Shouldn't be a next.
    assertFalse(iter.hasNext());
    assertTrue(iter.hasPrevious());
    assertEquals(3, iter.nextIndex());
    assertEquals(2, iter.previousIndex());

    // Shouldn't increment
    assertNull(iter.next());
    assertEquals(3, iter.nextIndex());
    assertEquals(2, iter.previousIndex());
    assertNull(iter.next());
    assertEquals(3, iter.nextIndex());
    assertEquals(2, iter.previousIndex());
    assertNull(iter.next());
    assertEquals(3, iter.nextIndex());
    assertEquals(2, iter.previousIndex());

    // Backtrack one.
    VoteBlock vb3 = (VoteBlock)iter.previous();
    assertNotNull(vb3);
    assertEquals(2, iter.nextIndex());
    assertEquals(1, iter.previousIndex());
    assertEquals(vb3, (VoteBlock)voteBlockList.get(2));
    
    // Backtrack two.
    VoteBlock vb4 = (VoteBlock)iter.previous();
    assertNotNull(vb4);
    assertEquals(1, iter.nextIndex());
    assertEquals(0, iter.previousIndex());
    assertEquals(vb4, (VoteBlock)voteBlockList.get(1));
    
    // Backtrack three.
    VoteBlock vb5 = (VoteBlock)iter.previous();
    assertNotNull(vb5);
    assertEquals(0, iter.nextIndex());
    assertEquals(-1, iter.previousIndex());
    assertEquals(vb5, (VoteBlock)voteBlockList.get(0));
    
    // No previous.
    assertFalse(iter.hasPrevious());
    assertTrue(iter.hasNext());
    
    assertNull(iter.previous());
    
    assertEquals(0, iter.nextIndex());
    assertEquals(-1, iter.previousIndex());
    
    // Ensure we can go forward and backward.
    // Not implemented
    try {
      iter.add(new Object());
      fail("Should have thrown UnsupportedOperationException");
    } catch (UnsupportedOperationException ex) {
      ; // expected
    }
    // Not implemented
    try {
      iter.remove();
      fail("Should have thrown UnsupportedOperationException");
    } catch (UnsupportedOperationException ex) {
      ; // expected
    }
    // Not implemented
    try {
      iter.set(new Object());
      fail("Should have thrown UnsupportedOperationException");
    } catch (UnsupportedOperationException ex) {
      ; // expected
    }
  }

  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.getVoteBlock(int)'
   */
  public void testGetVoteBlock() throws Exception {
    List voteBlockList = V3TestUtils.makeVoteBlockList(10);
    DiskVoteBlocks dvb = makeDiskVoteBlocks(voteBlockList);

    for (int i = 0; i <  voteBlockList.size(); i++) {
      assertEquals((VoteBlock)voteBlockList.get(i), dvb.getVoteBlock(i));
    }
    
  }

  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.size()'
   */
  public void testSize() throws Exception {
    List voteBlockList = V3TestUtils.makeVoteBlockList(10);
    DiskVoteBlocks dvb = makeDiskVoteBlocks(voteBlockList);
    assertEquals(dvb.size(), 10);
  }

  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.delete()'
   */
  public void testDelete() {
    // XXX:  To do.
  }

  /*
   * Test method for 'org.lockss.protocol.DiskVoteBlocks.getInputStream()'
   */
  public void testGetInputStream() throws Exception {
    List voteBlockList = V3TestUtils.makeVoteBlockList(10);
    DiskVoteBlocks dvb = makeDiskVoteBlocks(voteBlockList);
    InputStream is = dvb.getInputStream();
    
    assertNotNull(is);
    assertTrue(is instanceof InputStream);
  }
  
  private DiskVoteBlocks makeDiskVoteBlocks(List voteBlockList)
      throws Exception {
    DiskVoteBlocks dvb = new DiskVoteBlocks(tempDir);
    for (Iterator iter = voteBlockList.iterator(); iter.hasNext(); ) {
      VoteBlock vb = (VoteBlock)iter.next();
      dvb.addVoteBlock(vb);
    }
    return dvb;
  }

}
