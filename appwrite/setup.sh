#!/bin/bash

# Delete existing collections
echo "Deleting existing collections..."
appwrite databases delete-collection --database-id "67a247c300211b53cde4" --collection-id "videos" || true
appwrite databases delete-collection --database-id "67a247c300211b53cde4" --collection-id "likes" || true
appwrite databases delete-collection --database-id "67a247c300211b53cde4" --collection-id "comments" || true
appwrite databases delete-collection --database-id "67a247c300211b53cde4" --collection-id "users" || true

# Delete existing buckets
echo "Deleting existing buckets..."
appwrite storage delete-bucket --bucket-id "videos" || true
appwrite storage delete-bucket --bucket-id "thumbnails" || true

echo "Waiting for deletions to complete..."
sleep 5

# Create collections
echo "Creating collections..."
appwrite databases create-collection \
    --database-id "67a247c300211b53cde4" \
    --collection-id "videos" \
    --name "Videos" \
    --permissions "read(\"any\")" \
    --permissions "create(\"users\")" \
    --permissions "update(\"users\")" \
    --permissions "delete(\"users\")"

appwrite databases create-collection \
    --database-id "67a247c300211b53cde4" \
    --collection-id "likes" \
    --name "Likes" \
    --permissions "read(\"any\")" \
    --permissions "create(\"users\")" \
    --permissions "update(\"users\")" \
    --permissions "delete(\"users\")"

appwrite databases create-collection \
    --database-id "67a247c300211b53cde4" \
    --collection-id "comments" \
    --name "Comments" \
    --permissions "read(\"any\")" \
    --permissions "create(\"users\")" \
    --permissions "update(\"users\")" \
    --permissions "delete(\"users\")"

appwrite databases create-collection \
    --database-id "67a247c300211b53cde4" \
    --collection-id "users" \
    --name "Users" \
    --permissions "read(\"any\")" \
    --permissions "create(\"users\")" \
    --permissions "update(\"users\")" \
    --permissions "delete(\"users\")"

# Create storage buckets
echo "Creating storage buckets..."
appwrite storage create-bucket \
    --bucket-id "videos" \
    --name "Videos" \
    --permissions "read(\"any\")" \
    --permissions "create(\"users\")" \
    --permissions "update(\"users\")" \
    --permissions "delete(\"users\")" \
    --file-security true \
    --enabled true \
    --maximum-file-size 50000000 \
    --allowed-file-extensions ".mp4" \
    --allowed-file-extensions ".mov" \
    --allowed-file-extensions ".m4v"

appwrite storage create-bucket \
    --bucket-id "thumbnails" \
    --name "Thumbnails" \
    --permissions "read(\"any\")" \
    --permissions "create(\"users\")" \
    --permissions "update(\"users\")" \
    --permissions "delete(\"users\")" \
    --file-security true \
    --enabled true \
    --maximum-file-size 5000000 \
    --allowed-file-extensions ".jpg" \
    --allowed-file-extensions ".jpeg" \
    --allowed-file-extensions ".png"

echo "Creating attributes for videos collection..."
# Add attributes to videos collection
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "title" --size 256 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "caption" --size 1000 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "authorId" --size 255 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "author" --size 256 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "videoFileId" --size 255 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "thumbnailFileId" --size 255 --required false --xdefault ""
appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "likes" --required false --min 0 --xdefault 0
appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "comments" --required false --min 0 --xdefault 0
appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "shares" --required false --min 0 --xdefault 0
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "createdAt" --required false --xdefault 0

echo "Creating attributes for likes collection..."
# Add attributes to likes collection
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "userId" --size 255 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "videoId" --size 255 --required false --xdefault ""
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "createdAt" --required false --xdefault 0

echo "Creating attributes for comments collection..."
# Add attributes to comments collection
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "userId" --size 255 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "videoId" --size 255 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "text" --size 1000 --required false --xdefault ""
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "createdAt" --required false --xdefault 0

echo "Creating attributes for users collection..."
# Add attributes to users collection
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "username" --size 256 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "name" --size 256 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "bio" --size 1000 --required false --xdefault ""
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "avatarFileId" --size 255 --required false --xdefault ""
appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "followersCount" --required false --min 0 --xdefault 0
appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "followingCount" --required false --min 0 --xdefault 0
appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "videosCount" --required false --min 0 --xdefault 0
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "createdAt" --required false --xdefault 0

echo "Updating attributes to required..."
# Update video attributes to required
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "title" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "caption" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "authorId" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "author" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "videoFileId" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "thumbnailFileId" --required true
appwrite databases update-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "likes" --required true
appwrite databases update-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "comments" --required true
appwrite databases update-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "shares" --required true
appwrite databases update-float-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "createdAt" --required true

# Update likes attributes to required
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "userId" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "videoId" --required true
appwrite databases update-float-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "createdAt" --required true

# Update comments attributes to required
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "userId" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "videoId" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "text" --required true
appwrite databases update-float-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "createdAt" --required true

# Update users attributes to required
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "username" --required true
appwrite databases update-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "name" --required true
appwrite databases update-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "followersCount" --required true
appwrite databases update-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "followingCount" --required true
appwrite databases update-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "videosCount" --required true
appwrite databases update-float-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "createdAt" --required true

echo "Creating indexes..."
# Create indexes for videos collection
appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "videos" \
    --key "by_author" \
    --type "key" \
    --attributes authorId

appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "videos" \
    --key "by_created" \
    --type "key" \
    --attributes createdAt \
    --orders DESC

# Create indexes for likes collection
appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "likes" \
    --key "by_user_video" \
    --type "key" \
    --attributes userId \
    --attributes videoId

appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "likes" \
    --key "by_video" \
    --type "key" \
    --attributes videoId

# Create indexes for comments collection
appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "comments" \
    --key "by_video" \
    --type "key" \
    --attributes videoId \
    --attributes createdAt \
    --orders DESC

appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "comments" \
    --key "by_user" \
    --type "key" \
    --attributes userId \
    --attributes createdAt \
    --orders DESC

# Create indexes for users collection
appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "users" \
    --key "by_username" \
    --type "key" \
    --attributes username

appwrite databases create-index \
    --database-id "67a247c300211b53cde4" \
    --collection-id "users" \
    --key "by_created" \
    --type "key" \
    --attributes createdAt \
    --orders DESC

echo "Setup complete!" 