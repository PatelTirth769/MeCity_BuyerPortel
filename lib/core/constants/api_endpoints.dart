class ApiEndpoints {
  static const String baseUrl = 'https://marketplace.mecity.in/api/v2';

  // Auth & Profile
  static const String login = '$baseUrl/user/login-user';
  static const String register = '$baseUrl/user/create-user';
  static const String forgotPassword = '$baseUrl/user/forgot-password';
  static const String resetPassword = '$baseUrl/user/reset-password';
  static const String getUserProfile = '$baseUrl/user/getuser';
  static const String updateUserProfile = '$baseUrl/user/update-user-info';
  static const String updateUserAvatar = '$baseUrl/user/update-avatar';
  static const String logout = '$baseUrl/user/logout';
  static const String updatePassword = '$baseUrl/user/update-user-password';
  static const String updateUserAddresses = '$baseUrl/user/update-user-addresses';
  static const String deleteUserAddress = '$baseUrl/user/delete-user-address';

  // Products
  static const String getAllProducts = '$baseUrl/product/get-all-products';
  static const String getAllProductsShop = '$baseUrl/product/get-all-products-shop';
  static const String createNewReview = '$baseUrl/product/create-new-review';

  // Categories
  static const String getAllCategories = '$baseUrl/category/get-all-categories';
  static const String getAllSubCategories = '$baseUrl/category/get-all-subcategories';

  // Shops / Sellers
  static const String getAllShops = '$baseUrl/shop/get-all-shops';
  static const String getShopInfo = '$baseUrl/shop/get-shop-info';
  static const String getShopsNearMe = '$baseUrl/shop/get-shops-near-me';

  // Events
  static const String getAllEvents = '$baseUrl/event/get-all-events';
  static const String getAllEventsForShop = '$baseUrl/event/get-all-events';

  // Orders
  static const String getAllOrders = '$baseUrl/order/get-all-orders';
  static const String createOrder = '$baseUrl/order/create-order';
  static const String orderRefund = '$baseUrl/order/order-refund';

  // Chat
  static const String getAllConversations = '$baseUrl/conversation/get-all-conversation-user';
  static const String createConversation = '$baseUrl/conversation/create-new-conversation';
  static const String getAllMessages = '$baseUrl/message/get-all-messages';
  static const String createMessage = '$baseUrl/message/create-new-message';

  // Inquiry / Contact
  static const String createInquiry = '$baseUrl/inquiry/create-inquiry';

  // WhatsApp
  static const String whatsappProductInquiry = '$baseUrl/whatsapp/product-inquiry';
  static const String whatsappSendOtp = '$baseUrl/whatsapp/send-otp';
  static const String whatsappSendMessage = '$baseUrl/whatsapp/send-message';

  // Coupons
  static const String getCouponValue = '$baseUrl/coupon/get-coupon-value';

  // Blogs
  static const String getAllBlogs = '$baseUrl/blog/get-all-blogs';

  // Terms & Conditions
  static const String getUserTerms = '$baseUrl/terms/get-user-terms';

  // Payment
  static const String getStripeApiKey = '$baseUrl/payment/stripeapikey';
}
