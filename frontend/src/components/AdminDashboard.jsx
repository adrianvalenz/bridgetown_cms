import React, { useState, useEffect } from "react";

const AdminDashboard = () => {
  const [posts, setPosts] = useState([]);
  const [newPost, setNewPost] = useState({ title: "", content: ""});
  const [editMode, setEditMode] = useState(false);
  const [postToEdit, setPostToEdit] = useState(null);

  useEffect(() => {
    fetch("/api/posts")
      .then((response) => response.json())
      .then((data) => setPosts(data))
      .catch((error) => console.error("Error fetching posts:", error));
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewPost({ ...newPost, [name]: value });
  };

  const handleAddPost = () => {
    fetch("/api/posts", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newPost),
    })
      .then((response) => response.json())
      .then((data) => {
        setPosts([...posts, { id: data.filename, title: newPost.title, content: newPost.content }]);
        setNewPost({ title: "", content: "" });
      })
      .catch((error) => console.error("Error adding post:", error));
  };

  const handleEditPost = (post) => {
    setEditMode(true);
    setPostToEdit(post);
    setNewPost({ title: post.title, content: post.content });
  };

  const handleUpdatePost = () => {
    fetch(`/api/posts/${postToEdit.id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newPost),
    })
      .then((response) => response.json())
      .then((updatedPost) => {
        setPosts(posts.map((post) => (post.id === postToEdit.id ? { ...postToEdit, ...newPost } : post)));
        setNewPost({ title: "", content: "" });
        setEditMode(false);
        setPostToEdit(null);
      })
      .catch((error) => console.error("Error updating post:", error));
  }

  const handleCancelEdit = () => {
    setEditMode(false);
    setPostToEdit(null);
    setNewPost({ title: "", content: "" });
  }

  const handleDeletePost = (id) => {
    fetch(`/api/posts/${id}`, {
      method: "DELETE",
    })
      .then(() => {
        setPosts(posts.filter((post) => post.id !== id));
      })
      .catch((error) => console.error("Error deleting post:", error));
  };

  return (
    <div>
      <h1>Admin Dashboard</h1>
      
      <h2>All Posts</h2>
      <ul>
        {posts.map((post) => (
          <li key={post.id}>
            <h3>{post.title}</h3>
            <p>{post.content}</p>
            <button onClick={() => handleEditPost(post)}>Edit</button>
            <button onClick={() => handleDeletePost(post.id)}>Delete</button>
          </li>
        ))}
      </ul>

      <h2>{editMode ? "Edit Post" : "Create New Post"}</h2>
      <input
        type="text"
        name="title"
        value={newPost.title}
        placeholder="Title"
        onChange={handleInputChange}
      />
      <textarea
        name="content"
        value={newPost.content}
        placeholder="Content"
        onChange={handleInputChange}
      />
      {editMode ? (
        <>
          <button onClick={handleUpdatePost}>Update Post</button>
          <button onClick={handleCancelEdit}>Cancel Edit</button>
        </>
      ) : (
        <button onClick={handleAddPost}>Add Post</button>
      )}
    </div>
  );
};

export default AdminDashboard;
