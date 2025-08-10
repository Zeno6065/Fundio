# Firebase Structure

## Collections

accounts/{accountId}
- adminId
- currency
- targetAmount
- maturityDate
- withdrawalRules
- members: [userId, ...]
- pendingRequests: [{ userId, requestedAt, status }]

invites/{inviteId}
- accountId
- token
- expiresAt
- createdBy

users/{userId}
- username
- email
- defaultCurrency
- createdAt

deposits/{depositId}
- accountId
- userId
- amount
- originalCurrency
- proofUrl
- status
