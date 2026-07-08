/* ============================================================
   متجر بداية — منطق السلة والطلب عبر الواتساب
   بدون أي مكتبات خارجية (Vanilla JS)
   ============================================================ */
(function () {
  "use strict";

  /* ----------------------------------------------------------
     الإعدادات — غيّر رقم الواتساب هنا (بصيغة دولية بدون +)
     ---------------------------------------------------------- */
  var CONFIG = {
    // رقم متجر بداية على الواتساب — استبدله برقمك الحقيقي
    WHATSAPP_NUMBER: "218910000000",
    STORE_NAME: "متجر بداية",
    CURRENCY: "د.ل",
    STORAGE_KEY: "bidaya_cart_v1"
  };

  // موديلات الآيباد المتاحة
  var MODELS = [
    "iPad Pro 13",
    "iPad Pro 11",
    "iPad Air 13",
    "iPad Air 5",
    "iPad 10.9",
    "iPad Mini 6"
  ];

  // الألوان المتاحة
  var COLORS = [
    "أسود", "فضي", "رمادي", "كحلي", "بني",
    "وردي", "بنفسجي", "تركوازي", "ذهبي", "أخضر"
  ];

  /* ---------------------------- الحالة ---------------------------- */
  var cart = loadCart();

  /* ---------------------------- أدوات مساعدة ---------------------------- */
  function parsePrice(text) {
    var m = (text || "").replace(/[^\d]/g, "");
    return m ? parseInt(m, 10) : 0;
  }

  function formatPrice(n) {
    return n.toLocaleString("en-US") + " " + CONFIG.CURRENCY;
  }

  function itemKey(name, model, color) {
    return [name, model, color].join("||");
  }

  function loadCart() {
    try {
      var raw = localStorage.getItem(CONFIG.STORAGE_KEY);
      var data = raw ? JSON.parse(raw) : [];
      return Array.isArray(data) ? data : [];
    } catch (e) {
      return [];
    }
  }

  function saveCart() {
    try {
      localStorage.setItem(CONFIG.STORAGE_KEY, JSON.stringify(cart));
    } catch (e) {
      /* التخزين غير متاح — تجاهل بصمت */
    }
  }

  function makeSelect(className, options) {
    var sel = document.createElement("select");
    sel.className = className;
    options.forEach(function (opt) {
      var o = document.createElement("option");
      o.value = opt;
      o.textContent = opt;
      sel.appendChild(o);
    });
    return sel;
  }

  /* ---------------------------- بناء خيارات المنتج ---------------------------- */
  function enhanceProductCards() {
    var cards = document.querySelectorAll(".product-card");
    cards.forEach(function (card) {
      var btn = card.querySelector(".btn-small");
      // تجاهل البطاقات المعطّلة (قسم الأطفال "يتوفر قريباً")
      if (!btn || btn.disabled) return;

      var footer = card.querySelector(".product-footer");
      if (!footer) return;
      var body = footer.parentNode;

      var wrap = document.createElement("div");
      wrap.className = "product-options";

      var modelLabel = document.createElement("label");
      modelLabel.className = "opt";
      modelLabel.innerHTML = "<span>الموديل</span>";
      var modelSel = makeSelect("opt-model", MODELS);
      modelLabel.appendChild(modelSel);

      var colorLabel = document.createElement("label");
      colorLabel.className = "opt";
      colorLabel.innerHTML = "<span>اللون</span>";
      var colorSel = makeSelect("opt-color", COLORS);
      colorLabel.appendChild(colorSel);

      wrap.appendChild(modelLabel);
      wrap.appendChild(colorLabel);
      body.insertBefore(wrap, footer);

      btn.addEventListener("click", function () {
        var name = (card.querySelector(".product-name") || {}).textContent || "منتج";
        var price = parsePrice((card.querySelector(".product-price") || {}).textContent);
        addItem({
          name: name.trim(),
          model: modelSel.value,
          color: colorSel.value,
          price: price
        });
        openCart();
        flashButton(btn);
      });
    });
  }

  function flashButton(btn) {
    var original = btn.textContent;
    btn.textContent = "تمت الإضافة ✓";
    btn.classList.add("added");
    setTimeout(function () {
      btn.textContent = original;
      btn.classList.remove("added");
    }, 1000);
  }

  /* ---------------------------- عمليات السلة ---------------------------- */
  function addItem(item) {
    var key = itemKey(item.name, item.model, item.color);
    var existing = cart.filter(function (c) { return c.key === key; })[0];
    if (existing) {
      existing.qty += 1;
    } else {
      cart.push({
        key: key,
        name: item.name,
        model: item.model,
        color: item.color,
        price: item.price,
        qty: 1
      });
    }
    saveCart();
    renderCart();
  }

  function changeQty(key, delta) {
    var item = cart.filter(function (c) { return c.key === key; })[0];
    if (!item) return;
    item.qty += delta;
    if (item.qty <= 0) {
      cart = cart.filter(function (c) { return c.key !== key; });
    }
    saveCart();
    renderCart();
  }

  function removeItem(key) {
    cart = cart.filter(function (c) { return c.key !== key; });
    saveCart();
    renderCart();
  }

  function cartTotal() {
    return cart.reduce(function (sum, c) { return sum + c.price * c.qty; }, 0);
  }

  function cartCount() {
    return cart.reduce(function (sum, c) { return sum + c.qty; }, 0);
  }

  /* ---------------------------- عرض السلة ---------------------------- */
  var els = {};

  function renderCart() {
    var list = els.items;
    // إزالة عناصر المنتجات القديمة مع الإبقاء على رسالة الفراغ
    Array.prototype.slice.call(list.querySelectorAll(".cart-item")).forEach(function (n) {
      n.remove();
    });

    if (cart.length === 0) {
      els.empty.hidden = false;
    } else {
      els.empty.hidden = true;
      cart.forEach(function (item) {
        list.appendChild(buildCartItem(item));
      });
    }

    els.total.textContent = formatPrice(cartTotal());
    var count = cartCount();
    els.count.textContent = String(count);
    els.count.classList.toggle("has-items", count > 0);
  }

  function buildCartItem(item) {
    var row = document.createElement("div");
    row.className = "cart-item";

    var info = document.createElement("div");
    info.className = "cart-item-info";
    info.innerHTML =
      '<span class="cart-item-name"></span>' +
      '<span class="cart-item-meta"></span>' +
      '<span class="cart-item-price"></span>';
    info.querySelector(".cart-item-name").textContent = item.name;
    info.querySelector(".cart-item-meta").textContent =
      item.model + " · " + item.color;
    info.querySelector(".cart-item-price").textContent =
      formatPrice(item.price * item.qty);

    var controls = document.createElement("div");
    controls.className = "cart-item-controls";

    var minus = document.createElement("button");
    minus.type = "button";
    minus.className = "qty-btn";
    minus.setAttribute("aria-label", "إنقاص الكمية");
    minus.textContent = "−";
    minus.addEventListener("click", function () { changeQty(item.key, -1); });

    var qty = document.createElement("span");
    qty.className = "qty-val";
    qty.textContent = String(item.qty);

    var plus = document.createElement("button");
    plus.type = "button";
    plus.className = "qty-btn";
    plus.setAttribute("aria-label", "زيادة الكمية");
    plus.textContent = "+";
    plus.addEventListener("click", function () { changeQty(item.key, 1); });

    var remove = document.createElement("button");
    remove.type = "button";
    remove.className = "remove-btn";
    remove.setAttribute("aria-label", "حذف المنتج");
    remove.textContent = "حذف";
    remove.addEventListener("click", function () { removeItem(item.key); });

    controls.appendChild(minus);
    controls.appendChild(qty);
    controls.appendChild(plus);
    controls.appendChild(remove);

    row.appendChild(info);
    row.appendChild(controls);
    return row;
  }

  /* ---------------------------- فتح/إغلاق السلة ---------------------------- */
  function openCart() {
    els.panel.classList.add("open");
    els.panel.setAttribute("aria-hidden", "false");
    els.backdrop.hidden = false;
    document.body.classList.add("cart-lock");
  }

  function closeCart() {
    els.panel.classList.remove("open");
    els.panel.setAttribute("aria-hidden", "true");
    els.backdrop.hidden = true;
    document.body.classList.remove("cart-lock");
  }

  /* ---------------------------- تأكيد الطلب عبر الواتساب ---------------------------- */
  function buildWhatsappMessage(customer) {
    var lines = [];
    lines.push("مرحباً " + CONFIG.STORE_NAME + "، أرغب في تأكيد الطلب التالي:");
    lines.push("");
    lines.push("👤 الاسم: " + customer.name);
    lines.push("📱 الهاتف: " + customer.phone);
    lines.push("🏙️ المدينة: " + customer.city);
    lines.push("");
    lines.push("🛍️ تفاصيل الطلب:");
    cart.forEach(function (item, i) {
      lines.push(
        (i + 1) + ". " + item.name +
        " — الموديل: " + item.model +
        " — اللون: " + item.color +
        " — الكمية: " + item.qty +
        " — " + formatPrice(item.price * item.qty)
      );
    });
    lines.push("");
    lines.push("💰 المجموع الإجمالي: " + formatPrice(cartTotal()));
    return lines.join("\n");
  }

  function handleCheckout(e) {
    e.preventDefault();
    els.error.hidden = true;

    if (cart.length === 0) {
      showError("سلتك فارغة — أضف منتجاً واحداً على الأقل قبل تأكيد الطلب.");
      return;
    }

    var name = els.name.value.trim();
    var phone = els.phone.value.trim();
    var city = els.city.value.trim();

    if (!name || !phone || !city) {
      showError("يرجى تعبئة الاسم ورقم الهاتف والمدينة.");
      return;
    }

    var msg = buildWhatsappMessage({ name: name, phone: phone, city: city });
    var url = "https://wa.me/" + CONFIG.WHATSAPP_NUMBER +
      "?text=" + encodeURIComponent(msg);
    window.open(url, "_blank");
  }

  function showError(text) {
    els.error.textContent = text;
    els.error.hidden = false;
  }

  /* ---------------------------- التهيئة ---------------------------- */
  function init() {
    els.panel = document.getElementById("cart-panel");
    els.backdrop = document.getElementById("cart-backdrop");
    els.items = document.getElementById("cart-items");
    els.empty = document.getElementById("cart-empty");
    els.total = document.getElementById("cart-total");
    els.count = document.getElementById("cart-count");
    els.name = document.getElementById("cust-name");
    els.phone = document.getElementById("cust-phone");
    els.city = document.getElementById("cust-city");
    els.error = document.getElementById("checkout-error");

    enhanceProductCards();

    document.getElementById("cart-open").addEventListener("click", openCart);
    document.getElementById("cart-close").addEventListener("click", closeCart);
    els.backdrop.addEventListener("click", closeCart);
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") closeCart();
    });
    document.getElementById("checkout-form").addEventListener("submit", handleCheckout);

    renderCart();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
