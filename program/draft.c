int ll_http_read_line(struct ccstate* s) {
  struct httpconnect* conn = robot_get_specific(s);
  if (!conn->rxbuf) {
    conn->rxbuf = ccnewbuffer(ccgetthread(s), conn->maxlimit);
  }
  if (!conn->lstart) {
    conn->lstart = rxbuf->a + rxbuf->size;
    conn->mstart = conn->lstart;
  }
  nauty_int count = 0, n = 0;
ReadSocket:
  ccbufer_ensureremainsize(rxbuf, 128);
  count = rxbuf->capacity - rxbuf->size;
  n = ccsocket_read(sock, rxbuf->a + rxbuf->size, count, &status);
  if (status < 0) {
    return CCSTATUS_EREAD;
  }
  const char* e = ccstring_matchuntil(newlines, conn->mstart, rxbuf->a + rxbuf->size + n - conn->mstart, &tooshort);
  if (e == 0 || tooshort) { /* no newline exist current or string tooshort */
    rxbuf->size += n;
    if (rxbuf->size > conn->maxlimit) {
      return CCSTATUS_ELIMIT;
    }
    if (e == 0) {
      conn->mstart = rxbuf->a + rxbuf->size;
    } else {
      conn->mstart = /* prev non-newline char pos */
    }
    if (n < count) {
      return CCSTATUS_WAITMORE;
    }
    goto ReadSocket;
  }
  /* newline matched */
  conn->lnewline = e;
  conn->lend = e + tooshort;
  if (n < count) {
    return 0; 
  }
  return CCSTATUS_CONTREAD;
}

int ll_http_read_startline(struct ccstate* s) {
  int n = ll_http_read_line(s);
  if (n == CCSTATUS_EREAD || n == CCSTATUS_ELIMIT) {
    return n;
  }
  if (n == CCSTATUS_WAITMORE) {
    return robot_yield(s, ll_http_read_startline);
  }
  /* the start line is read */
  const char* e = string_skipheadspacesmatch(ccmethods, conn->lstart, conn->lnewline - conn->lstart, &strid);
  if (e == 0) {
    return CCSTATUS_EMATCH;
  }
  /* method define order need to be the same as the orlist define oreder */
  conn->method = strid;
  e = string_skipheadspacesmatch(ccnonblanks, e, conn->lnewline - e, &len);
  if (e == 0) {
    return CCSTATUS_EMATCH;
  }
  conn->us = e - len;
  conn->ue = e;
  e = string_skipheadspacematch(ccheepver, e, conn->lnewline - e, &len);
  if (e == 0) {
    conn->httpver = HTTP_VER_0_9;
    return 0; /* head read finished for v0.9 */
  }
  conn->httpver = /* httpstrid */
  if (n == CCSTATUS_CONTREAD) {
    return ll_http_read_headers(s);
  }
  return robot_yield(s, ll_http_read_headers);
}
