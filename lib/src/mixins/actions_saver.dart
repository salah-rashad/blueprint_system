// import 'package:get/get.dart';
// import 'package:undo/undo.dart';

// mixin ActionsSaver {
//   var actions = ChangeStack();

//   void saveAction<T>(Rx<T> rx, T to, [T? old]) {
//     actions.add(
//       Change<T>(
//         old ?? rx.value,
//         () => rx.value = to,
//         (oldValue) => rx.value = oldValue,
//       ),
//     );
//     print("saved");
//   }
// }

// // extension A on Object {
// //   void to(ChangeStack stack, dynamic value) {
// //     stack.add(
// //       Change<T>(
// //         variable,
// //         () => variable = to,
// //         (oldValue) => variable = oldValue,
// //       ),
// //     );
// //   }
// // }
