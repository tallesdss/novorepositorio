import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/recipes/recipes_list_screen.dart';
import '../screens/recipes/recipe_detail_screen.dart';
import '../screens/recipes/recipe_form_screen.dart';
import '../screens/recipes/my_recipes_screen.dart';
import '../screens/search/search_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Rotas de Autenticação
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Rotas Principais
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      
      // Rotas de Receitas
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) => const RecipesListScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        name: 'recipe-detail',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeDetailScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/create-recipe',
        name: 'create-recipe',
        builder: (context, state) => const RecipeFormScreen(),
      ),
      GoRoute(
        path: '/edit-recipe/:id',
        name: 'edit-recipe',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeFormScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/my-recipes',
        name: 'my-recipes',
        builder: (context, state) => const MyRecipesScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
}
