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

  // If authenticated and trying to access login/signup, redirect to home
  // But allow welcome page (/) for testing the full flow
  if (authenticated && location == '/login') {
    return '/home';
  }

  if (authenticated && location == '/signup') {
    return '/home';
  }

  return null;
}
