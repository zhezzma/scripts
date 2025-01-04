import fs from 'fs';
import crypto from 'crypto';
const hobbies = ['kanshu', 'game', 'yundong', 'muscic', 'dianying', 'lvyou', 'meishi', 'sheying', 'huihua', 'xiezuo'];

// 生成随机账号
function generateAccount() {
    //将大写的L改成随机26个字母大写
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const randomLetter = letters.charAt(Math.floor(Math.random() * letters.length));
    return randomLetter + Math.floor(10000000 + Math.random() * 90000000);
}

// 生成随机密码
function generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const length = Math.floor(Math.random() * 10) + 8;
    let password = '';
    for (let i = 0; i < length; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
}

// 获取随机爱好
function getRandomHobby() {
    return hobbies[Math.floor(Math.random() * hobbies.length)];
}

// MD5加密函数
function md5(text) {
    return crypto.createHash('md5').update(text).digest('hex');
}

// 将对象转换为排序后的查询字符串
function jsonToSortedQueryString(obj) {
    const keys = Object.keys(obj).sort();
    const params = new URLSearchParams();
    keys.forEach((key) => {
        if (key !== 'sign') {
            params.append(key, obj[key]);
        }
    });
    return params.toString();
}

// 生成签名
function sign(params, keyCode) {
    return md5(jsonToSortedQueryString(params) + keyCode);
}

// 主函数
async function main() {
    const keyCode = "MLE!^Re4XcsrxBbR&!DvenL$";
    const accounts = [];
    let successAccounts = [];

    // 生成10个账号用于测试
    for (let i = 0; i < 20; i++) {
        const name = generateAccount();
        const account = {
            name: name,
            email: name,
            passwd: generatePassword(),
            question: '您最大的爱好是?',
            answer: getRandomHobby(),
            code: "0"
        };
        accounts.push(account);
    }

    // 注册账号
    for (const account of accounts) {
        const params = { ...account };
        params.sign = sign(params, keyCode);
        const body = new URLSearchParams(params).toString()
        console.log('正在注册：', account);
        console.log('注册参数：', body);
        try {
            const response = await fetch("https://www.tline.website/auth/register", {
                method: 'POST',
                headers: {
                    "accept": "application/json, text/javascript, */*; q=0.01",
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
                    "x-requested-with": "XMLHttpRequest"
                },
                body: body
            });
            if (!response.ok) {
                console.log(`账号 ${account.name} 注册失败: ${response.status},${response.statusText}`);
                continue;
            }
            const result = await response.json();
            if(result.ret != 1)
            {
                console.log(`账号 ${account.name} 注册失败,错误消息:${result.msg}`);
                continue;
            }
            successAccounts.push(account);
            console.log(`账号 ${account.name} 注册成功,${JSON.stringify(result)}`);
            await new Promise((resolve) => setTimeout(resolve, 1000)); // 等待1秒后再注册下一个账号
        } catch (error) {
            console.error(`账号 ${account.name} 注册出错:`, error);
        }
    }

    // 保存成功注册的账号
    if (successAccounts.length > 0) {
        const successCount = successAccounts.length;
        if (fs.existsSync('tline_accounts.json')) {
            const existingData = fs.readFileSync('tline_accounts.json', 'utf8');
            if (existingData.trim() !== '') {
                const existingAccounts = JSON.parse(existingData);
                successAccounts = existingAccounts.concat(successAccounts);
            }
        }
        fs.writeFileSync('tline_accounts.json', JSON.stringify(successAccounts, null, 2));
        console.log(`成功注册 ${successCount} 个账号，已保存到 tline_accounts.json`);
    }
}

main().catch(console.error);
