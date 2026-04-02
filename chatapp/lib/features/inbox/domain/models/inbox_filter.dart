enum InboxFilter {
  all('All'),
  unread('Unread'),
  pinned('Pinned');

  const InboxFilter(this.label);

  final String label;
}
