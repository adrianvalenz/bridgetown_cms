---
layout: bridgetown_cms/admin_layout
title: Admin Dashboard
permalink: /admin/
---

<div class="space-y-8">
  <!-- Page Header -->
  <div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-3xl font-bold text-gray-900 mb-2">Articles</h2>
    <p class="text-gray-600">Manage your blog posts and articles</p>
  </div>

  <!-- Article Form Section -->
  <div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-xl font-semibold text-gray-900 mb-4">Create New Article</h3>
    <!-- Article form will be loaded here via HTMX -->
    <div id="article-form-container"
         hx-get="/admin/article-form"
         hx-trigger="load"
         hx-swap="innerHTML">
      <!-- Loading indicator -->
      <div class="flex items-center justify-center py-4">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
        <span class="ml-2 text-gray-600 text-sm">Loading form...</span>
      </div>
    </div>
  </div>

  <!-- Articles List Section -->
  <div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-xl font-semibold text-gray-900 mb-4">All Articles</h3>
    <!-- Articles list will be loaded here via HTMX -->
    <div id="articles-list-container"
         hx-get="/admin/articles"
         hx-trigger="load"
         hx-target="#articles-list-container"
         hx-swap="innerHTML">
      <!-- Loading indicator -->
      <div class="flex items-center justify-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        <span class="ml-2 text-gray-600">Loading articles...</span>
      </div>
    </div>
  </div>
</div>
