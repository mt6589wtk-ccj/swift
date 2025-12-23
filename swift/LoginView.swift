import SwiftUI

struct LoginView: View {
    // 使用 Binding 連接到 ContentView 的登入狀態
    @Binding var isLoggedIn: Bool
    
    // 儲存輸入內容
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // 圖示與標題
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("匿名路徑紀錄")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("輸入帳號密碼以開始紀錄您的時間軸")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // 輸入欄位
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("帳號 (Username)", text: $username)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("密碼 (Password)", text: $password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 登入按鈕
                Button(action: login) {
                    Text("登入")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                Text("您的資料將以匿名形式儲存在本機")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .alert("提示", isPresented: $showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("請輸入帳號與密碼")
        }
    }
    
    // 簡單的登入邏輯判斷
    func login() {
        if username.isEmpty || password.isEmpty {
            showAlert = true
        } else {
            // 驗證成功，切換狀態
            withAnimation {
                isLoggedIn = true
            }
        }
    }
}

#Preview {
    // 預覽時傳入一個固定的狀態
    LoginView(isLoggedIn: .constant(false))
}
