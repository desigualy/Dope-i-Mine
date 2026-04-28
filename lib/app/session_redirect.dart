String? sessionRedirect({
  required bool authenticated,
  required String location,
}) {
  // Routes that can be accessed without authentication
  const unauthenticatedRoutes = <String>{
    '/',
    '/login',
    '/signup',
  };

  // Routes that redirect to login if not authenticated
  if (!authenticated && !unauthenticatedRoutes.contains(location)) {
    return '/login';
  }

  return null;
}
