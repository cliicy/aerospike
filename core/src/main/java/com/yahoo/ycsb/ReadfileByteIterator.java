/**
 * Copyright (c) 2010-2016 Yahoo! Inc., 2017 YCSB contributors All rights reserved.
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License. See accompanying
 * LICENSE file.
 */
package com.yahoo.ycsb;

import java.util.concurrent.ThreadLocalRandom;

/**
 *  A ByteIterator that generated from  certain compressed file.
 */
public class ReadfileByteIterator extends ByteIterator {
  private long len;
  private long off;
  private int bufOff;
  private byte[] buf;


  @Override
  public boolean hasNext() {
    return (off + bufOff) < len;
  }

  private void fillBytesImpl(byte[] buffer, int base) {
    int bytes = ThreadLocalRandom.current().nextInt();
    switch (buffer.length - base) {
    default:
      buffer[base + 5] = (byte) (((bytes >> 25) & 95) + ' ');
    case 5:
      buffer[base + 4] = (byte) (((bytes >> 20) & 63) + ' ');
    case 4:
      buffer[base + 3] = (byte) (((bytes >> 15) & 31) + ' ');
    case 3:
      buffer[base + 2] = (byte) (((bytes >> 10) & 95) + ' ');
    case 2:
      buffer[base + 1] = (byte) (((bytes >> 5) & 63) + ' ');
    case 1:
      buffer[base + 0] = (byte) (((bytes) & 31) + ' ');
    case 0:
      break;
    }
  }

  private void fillBytes() {
    if (bufOff == buf.length) {
      fillBytesImpl(buf, 0);
      bufOff = 0;
      off += buf.length;
    }
  }


/*
read data from compressed files
 */
  public ReadfileByteIterator(long len,long[] offset,byte[] dst) {
    this.off = 0;
    long datalen = dst.length;
    long gaplen = datalen - offset[0];

    this.len = len;
    this.buf = new byte[(int)len];
    int sz = 0;

    if ( offset[0] + len <= datalen ) {
      while (sz < this.buf.length) {
        this.buf[sz++] = dst[(int) offset[0]++];
      }
      if (gaplen == 0) {
        offset[0] = 0;
      }
    }
    else  { // offset[0] + len > datalen
      while (offset[0] <= datalen) {
        this.buf[sz++] = dst[(int) offset[0]++];
      }
      offset[0] = 0;
      while (offset[0] < gaplen) {
        this.buf[sz++] = dst[(int) offset[0]++];
      }
    }
  }

  public byte nextByte() {
    fillBytes();
    bufOff++;
    return buf[bufOff - 1];
  }

  @Override
  public int nextBuf(byte[] buffer, int bufOffset) {
    int ret;
    if (len - off < buffer.length - bufOffset) {
      ret = (int) (len - off);
    } else {
      ret = buffer.length - bufOffset;
    }
    int i;
    for (i = 0; i < ret; i += this.len) {
      fillBytesImpl(buffer, i + bufOffset);
    }
    off += ret;
    return ret + bufOffset;
  }

  @Override
  public long bytesLeft() {
    return len - off - bufOff;
  }

  @Override
  public void reset() {
    off = 0;
  }


  public byte[] toArray() {
//    String ss = new String(this.buf);
//    System.out.println("******* "+ss+" *******");
    return this.buf;
  }
  
}
