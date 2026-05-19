const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 🔔 إشعار للمسؤولين عند إضافة بلاغ جديد
exports.sendReportNotification = functions.firestore
    .document("reports/{reportId}")
    .onCreate((snap, context) => {
      const report = snap.data();
      const payload = {
        notification: {
          title: "بلاغ جديد",
          body: `نوع البلاغ: ${report.type} - ${
report.desc ? report.desc.substring(0, 50) : ""
          }...`,

        },
        data: {
          reportId: context.params.reportId,
          status: report.status || "pending",
        },
      };
      return admin.messaging().sendToTopic("admins", payload);
    });

// 🔔 إشعار للمستخدم عند تحديث حالة بلاغه
exports.notifyUserOnStatusChange = functions.firestore
    .document("reports/{reportId}")
    .onUpdate((change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      if (before.status !== after.status) {
        const payload = {
          notification: {
            title: "تحديث حالة البلاغ",
            body: `تم تغيير حالة بلاغك إلى: ${after.status}`,
          },
          data: {
            reportId: context.params.reportId,
            status: after.status,
          },
        };
        return admin.messaging().sendToTopic("users", payload);
      }
      return null;
    });
