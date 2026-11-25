#!/usr/bin/env python3
"""Build pkgdown/assets/cv-cheatsheet.html and cv-cheatsheet-zh.html.

A visual cheat sheet for cv_folds() / apply_folds() / cv_scenarios() /
export_scenarios(), in the spirit of the Posit purrr cheat sheet: one panel
per function, a signature, a sentence, a small block diagram and an example.

Styles and the R highlighter are taken from pkgdown/assets/cheatsheet.html so
both cheat sheets look the same. Run from the package root:

    python3 dev/cv_cheatsheet.py
"""
import json
import random
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = (ROOT / "pkgdown/assets/cheatsheet.html").read_text(encoding="utf-8")
BASE_CSS = re.search(r"<style>(.*?)</style>", BASE, re.S).group(1)
HL_JS = re.findall(r"<script>(.*?)</script>", BASE, re.S)[-1]
VERSION = re.search(r"^Version:\s*(\S+)", (ROOT / "DESCRIPTION").read_text(), re.M).group(1)

V = 5                      # folds in the diagrams
N = {"A": 10, "B": 8}      # individuals per herd in the static diagrams


def folds_for(n, seed):
    """Balanced random fold labels 1..V, like mintyr's .assign_folds()."""
    lab = [(i % V) + 1 for i in range(n)]
    random.Random(seed).shuffle(lab)
    return lab


F = {r: {h: folds_for(n, 100 * r + ord(h)) for h, n in N.items()} for r in (1, 2, 3, 4, 5)}


def q(cls, txt="", title=""):
    t = f' title="{title}"' if title else ""
    return f'<i class="q {cls}"{t}>{txt}</i>'


def strip(label, cells):
    return f'<div class="strip"><span class="lab">{label}</span><span class="cells">{"".join(cells)}</span></div>'


def fold_strip(label, herd, rep, tag=True):
    return strip(label, [q(f"f{f}", f if tag else "", f"{herd}{i + 1}: Fold{f}") for i, f in enumerate(F[rep][herd])])


def role_strip(label, herd, rep, k, role_other=None, target="A"):
    cells = []
    for i, f in enumerate(F[rep][herd]):
        if herd == target:
            cls = "va" if f == k else "tr"
        else:
            cls = role_other
        cells.append(q(cls, "", f"{herd}{i + 1}"))
    return strip(label, cells)


# ---------------------------------------------------------------------------
# Text
# ---------------------------------------------------------------------------
def build(lang):
    zh = lang == "zh"

    def L(en, cn):
        return cn if zh else en

    other = "cv-cheatsheet.html" if zh else "cv-cheatsheet-zh.html"
    article = "articles/genomic-evaluation-zh.html" if zh else "articles/genomic-evaluation.html"
    main_cs = "cheatsheet-zh.html" if zh else "cheatsheet.html"
    trait_rows = ["adg", "bf", "fcr"]

    # -- legend ---------------------------------------------------------------
    legend = (
        f'<div class="legend">'
        f'<span>{L("Fold", "折")}</span>' + "".join(q(f"f{i}", str(i)) for i in range(1, V + 1)) +
        f'<span class="sep"></span>{q("tr")}<span>{L("training", "训练集")}</span>'
        f'{q("va")}<span>{L("validation", "验证集")}</span>'
        f'{q("un")}<span>{L("not used", "不使用")}</span>'
        f'{q("tr na")}<span>{L("phenotype missing (row kept)", "表型缺失（行保留）")}</span>'
        f'<span class="sep"></span><span><b>A</b>, <b>B</b> = {L("herds (groups)", "群体（场）")}</span>'
        f'</div>'
    )

    # -- panel: cv_folds --------------------------------------------------------
    p_folds = f'''
<section class="panel cv">
  <h2><a href="reference/cv_folds.html">{L("Split individuals once", "按个体划分一次")}</a> <small>cv_folds()</small></h2>
  <div class="fn">
    <div class="sig"><b><a href="reference/cv_folds.html">cv_folds</a></b>(data, id, by = NULL, v = 5, repeats = 1, strata = NULL, seed = NULL)</div>
    <p>{L("Assigns every <b>individual</b> (not every row) to one of <code>v</code> folds, within each group, independently in each repeat.",
          "把每个<b>个体</b>（而不是每一行）分到 <code>v</code> 折之一；在每个群体内分别划分，每次重复相互独立。")}</p>
    <div class="dia">
      <div class="mini c2"><span class="h">id</span><span class="h">herd</span><span>A1</span><span>A</span><span>A2</span><span>A</span><span>&hellip;</span><span>&hellip;</span><span>B1</span><span>B</span><span>&hellip;</span><span>&hellip;</span></div>
      <span class="arrow">&rarr;</span>
      <div>
        <div class="cap">Repeat1</div>
        {fold_strip("A", "A", 1)}
        {fold_strip("B", "B", 1)}
        <div class="cap">Repeat2</div>
        {fold_strip("A", "A", 2)}
        {fold_strip("B", "B", 2)}
      </div>
    </div>
    <ul>
      <li>{L("Each individual appears exactly once per repeat; fold sizes differ by at most one.", "每次重复中每个个体恰好出现一次；各折大小最多相差 1。")}</li>
      <li>{L("Repeats are independent: an individual moves between folds.", "各次重复相互独立：同一个体在不同重复中落在不同的折。")}</li>
      <li>{L("All records of an individual stay in one fold (repeated records).", "同一个体的多条记录总在同一折（重复记录）。")}</li>
    </ul>
    <pre><code>folds &lt;- cv_folds(phe, id = "id", by = "herd",
  v = 5, repeats = 10, seed = 123)
folds   # herd | id | rep | fold</code></pre>
  </div>
</section>'''

    # -- panel: why one table ---------------------------------------------------
    per_trait = "".join(strip(t, [q(f"f{f}", str(f)) for f in folds_for(N["A"], 7 + j)]) for j, t in enumerate(trait_rows))
    shared = "".join(strip(t, [q(f"f{f}", str(f)) for f in F[1]["A"]]) for t in trait_rows)
    p_why = f'''
<section class="panel cv">
  <h2>{L("Same validation animals for every model", "所有模型用同一批验证个体")} <small>{L("why one table", "为什么只建一张表")}</small></h2>
  <div class="fn">
    <div class="vs">
      <div><div class="cap"><span class="bad">&#10007;</span> {L("<code>nest_cv()</code> per trait", "每个性状各自 <code>nest_cv()</code>")}</div>{per_trait}</div>
      <div><div class="cap"><span class="good">&#10003;</span> {L("<code>cv_folds()</code> once", "<code>cv_folds()</code> 只建一次")}</div>{shared}</div>
    </div>
    <p>{L("Left: <code>Fold1</code> of adg and of bf contain different animals, so a single-trait and a two-trait model are compared on different individuals. Right: every trait, trait pair and model takes its split from the same table, matched by ID.",
          "左：adg 和 bf 的 <code>Fold1</code> 是不同的个体，单性状模型和两性状模型其实在不同个体上比较。右：所有性状、性状对和模型都按 ID 从同一张表取划分。")}</p>
    <div class="note">{L("Pairing by repeat (and fold) is only valid when the validation individuals are identical.", "只有验证个体完全相同时，按重复（和折）配对比较才有意义。")}</div>
  </div>
</section>'''

    # -- panel: strata & extending repeats -------------------------------------
    sexes = ["M", "F", "M", "M", "F", "F", "M", "F", "M", "F"]
    by_fold = {k: [s for s, f in zip(sexes, F[1]["A"]) if f == k] for k in range(1, V + 1)}
    strata_html = "".join(
        f'<div class="fbox"><div class="cap">Fold{k}</div>' + "".join(q(f"f{k}", s) for s in sorted(by_fold[k])) + "</div>"
        for k in range(1, V + 1))
    p_strata = f'''
<section class="panel cv">
  <h2>{L("Stratify and extend", "分层与追加重复")} <small>cv_folds()</small></h2>
  <div class="fn">
    <div class="sig"><b>strata</b> = "sex"</div>
    <p>{L("Spreads a factor evenly over the folds. Must be constant within an individual; numeric columns are binned at quantiles.",
          "让某个因素在各折中均匀分布。分层列在个体内必须唯一；数值列先按分位数分箱。")}</p>
    <div class="folds-row">{strata_html}</div>
  </div>
  <div class="fn">
    <div class="sig"><b>repeats</b> = 3 &rarr; 5, {L("same", "同一个")} <b>seed</b></div>
    <p>{L("Repeats are generated one after another: increasing <code>repeats</code> keeps the existing repeats, so finished runs stay valid.",
          "各次重复依次生成：增大 <code>repeats</code> 不会改变已有的重复，已经跑完的结果可以继续使用。")}</p>
    {"".join(fold_strip(f"Repeat{r}", "A", r, tag=False) for r in (1, 2, 3))}
    {"".join(strip(f'Repeat{r} <span class="new">{L("new", "新")}</span>', [q(f"f{f}") for f in F[r]["A"]]) for r in (4, 5))}
  </div>
</section>'''

    # -- panel: apply_folds -------------------------------------------------------
    p_apply = f'''
<section class="panel cv">
  <h2><a href="reference/apply_folds.html">{L("Cut any nested table", "切分任意嵌套表")}</a> <small>apply_folds()</small></h2>
  <div class="fn">
    <div class="sig"><b><a href="reference/apply_folds.html">apply_folds</a></b>(data, folds, ref = "none", out_type = "dt")</div>
    <p>{L("For each target group, repeat and fold: validation = target group in this fold; training = target group in the other folds.",
          "对每个目标群体、每次重复、每一折：验证集 = 目标群体中属于该折的个体；训练集 = 目标群体其余各折。")}</p>
    <div class="cap">{L("target A, Repeat1, Fold1", "目标 A，Repeat1，Fold1")} &middot; <b>ref = "none"</b></div>
    {role_strip("A", "A", 1, 1)}
    {role_strip("B", "B", 1, 1, "un")}
    <div class="cap">{L("target A, Repeat1, Fold1", "目标 A，Repeat1，Fold1")} &middot; <b>ref = "others"</b></div>
    {role_strip("A", "A", 1, 1)}
    {role_strip("B", "B", 1, 1, "tr")}
    <p>{L("<code>ref = \"others\"</code> adds <b>all</b> records of the other groups to every training set; they are never validated.",
          "<code>ref = \"others\"</code> 把其他群体的<b>全部</b>记录加入每个训练集；它们不会被验证。")}</p>
  </div>
  <div class="fn">
    <p>{L("Input: any nested table &mdash; rows are matched to folds <b>by ID</b>, never by position.", "输入可以是任意嵌套表 &mdash; 按 <b>ID</b> 匹配折，而不是按行的位置。")}</p>
    <div class="dia">
      <div class="listbox"><span>w2l_nest()</span><span>c2p_nest()</span><span>r2p_nest()</span><span>{L("your own", "自己构建的")}</span></div>
      <span class="arrow">+</span>
      <div class="mini c4"><span class="h">herd</span><span class="h">id</span><span class="h">rep</span><span class="h">fold</span><span>A</span><span>A1</span><span>R1</span><span class="n">F3</span></div>
      <span class="arrow">&rarr;</span>
      <div class="mini c4"><span class="h">name</span><span class="h">herd</span><span class="h">rep &middot; fold</span><span class="h">train | validate</span><span>adg</span><span>A</span><span>R1 &middot; F1</span><span>&#9638; | &#9638;</span><span>adg</span><span>A</span><span>R1 &middot; F2</span><span>&#9638; | &#9638;</span><span>&hellip;</span><span>&hellip;</span><span>&hellip;</span><span>&hellip;</span></div>
    </div>
    <ul>
      <li>{L("Rows: nested rows &times; groups &times; repeats &times; folds.", "行数 = 嵌套行 &times; 群体 &times; 重复 &times; 折。")}</li>
      <li>{L("Nested rows that differ only in the group are merged; the group column is put back right after the ID.", "只在群体上不同的嵌套行会先合并；群体列放回到 ID 列之后。")}</li>
      <li>{L("IDs missing from <code>folds</code> are dropped with a warning.", "<code>folds</code> 中没有的 ID 会被剔除并给出警告。")}</li>
    </ul>
    <pre><code>nested &lt;- c2p_nest(phe, cols = c("adg", "bf"))
cv &lt;- apply_folds(nested, folds, ref = "others")</code></pre>
  </div>
</section>'''

    # -- five scenario cards ------------------------------------------------------
    def card(code, title, model, param, layout_cols, layout_rows, ref):
        tbl = (f'<div class="mini" style="grid-template-columns: repeat({len(layout_cols)}, auto)">' +
               "".join(f'<span class="h">{c}</span>' for c in layout_cols) +
               "".join(f'<span class="{cl}">{v}</span>' for row in layout_rows for v, cl in row) + "</div>")
        return f'''
  <div class="card">
    <div class="card-h"><code>{code}</code><span>{title}</span></div>
    <p class="model">{model}</p>
    <div class="kv"><span>{L("parameter data", "参数估计数据")}</span><b>{param}</b></div>
    <div class="cap">{L("file layout", "文件列布局")}</div>
    {tbl}
    <div class="cap">{L("target A &middot; Repeat1 &middot; Fold1", "目标 A &middot; Repeat1 &middot; Fold1")}</div>
    {role_strip("A", "A", 1, 1)}
    {role_strip("B", "B", 1, 1, "tr" if ref else "un")}
  </div>'''

    st_rows = [[("A1", ""), ("A", ""), ("M", ""), ("912", "a")], [("A2", ""), ("A", ""), ("F", ""), (".", "na-c")], [("B1", ""), ("B", ""), ("M", ""), ("880", "b")]]
    mt_rows = [[("A1", ""), ("A", ""), ("912", "a"), ("12.1", "a")], [("A2", ""), ("A", ""), (".", "na-c"), ("11.8", "a")], [("B1", ""), ("B", ""), ("880", "b"), ("13.0", "b")]]
    bt_rows = [[("A1", ""), ("A", ""), ("912", "a"), (".", "na-c")], [("A2", ""), ("A", ""), (".", "na-c"), (".", "na-c")], [("B1", ""), ("B", ""), (".", "na-c"), ("880", "b")]]
    cards = "".join([
        card("st_sp", L("single-trait, one group", "单性状 · 单群体"), L("Within-herd accuracy of a single-trait GBLUP.", "群体内单性状 GBLUP 的准确性。"),
             L("trait &times; group", "性状 &times; 群体"), ["id", "herd", "sex", "value"], st_rows, False),
        card("st_mp", L("single-trait, groups combined", "单性状 · 合并群体"), L("Does adding the other herd to the reference help?", "加入另一个群体作参考群能否提高准确性？"),
             L("trait", "性状"), ["id", "herd", "sex", "value"], st_rows, True),
        card("mt_sp", L("two-trait, one group", "两性状 · 单群体"), L("Does a correlated trait help, within the herd?", "群体内，相关性状能否提高准确性？"),
             L("trait pair &times; group", "性状对 &times; 群体"), ["id", "herd", "value1", "value2"], mt_rows, False),
        card("mt_mp", L("two-trait, groups combined", "两性状 · 合并群体"), L("Correlated trait and the other herd together.", "相关性状与另一个群体同时加入。"),
             L("trait pair", "性状对"), ["id", "herd", "value1", "value2"], mt_rows, True),
        card("mt_bt", L("one trait per group as two traits", "同一性状按群体视为两个性状"), L("Genetic correlation between herds; predicts across herds.", "估计群体间遗传相关，并跨群体预测。"),
             L("trait", "性状"), ["id", "herd", "A", "B"], bt_rows, True),
    ])
    p_cards = f'''
<section class="panel cv wide">
  <h2><a href="reference/cv_scenarios.html">{L("Five GBLUP scenarios in one call", "一次生成五个 GBLUP 场景")}</a> <small>cv_scenarios()</small></h2>
  <div class="fn">
    <div class="sig"><b><a href="reference/cv_scenarios.html">cv_scenarios</a></b>(data, cols, id, group, folds = NULL, v = 5, repeats = 1, seed = NULL, scenarios = c("st_sp", "st_mp", "mt_sp", "mt_mp", "mt_bt"))</div>
    <p>{L("Every scenario returns <code>param</code> (all records, for variance components) and <code>cv</code> (train / validate per group &times; repeat &times; fold). All five validate <b>the same individuals</b> &mdash; compare the A rows below.",
          "每个场景都返回 <code>param</code>（全部记录，用于估计方差组分）和 <code>cv</code>（每个群体 &times; 重复 &times; 折的训练集 / 验证集）。五个场景验证的是<b>同一批个体</b> &mdash; 对比下面各卡片中的 A 行。")}</p>
    <div class="cards">{cards}</div>
    <div class="note">{L("All files keep every non-trait column (including <code>herd</code>) in the original order, and keep rows with missing phenotypes, so the layout is the same across scenarios. Two-trait values are <code>value1</code>, <code>value2</code> in the order of <code>pairs</code>; <code>mt_bt</code> puts the trait in one column per group.",
                        "所有文件都按原始顺序保留全部非性状列（包括 <code>herd</code>），并保留表型缺失的行，各场景列布局一致。两性状的值在 <code>value1</code>、<code>value2</code>，顺序同 <code>pairs</code>；<code>mt_bt</code> 把性状按群体拆成多列。")}</div>
    <pre><code>sc &lt;- cv_scenarios(phe, cols = c("adg", "bf", "fcr"), id = "id", group = "herd", folds = folds)
sc$st_mp$param   # name | data
sc$st_mp$cv      # name | herd | rep | fold | train | validate</code></pre>
  </div>
</section>'''

    # -- export -------------------------------------------------------------------
    p_export = f'''
<section class="panel io">
  <h2><a href="reference/export_scenarios.html">{L("Write input files", "写出软件输入文件")}</a> <small>export_scenarios()</small></h2>
  <div class="fn">
    <div class="sig"><b><a href="reference/export_scenarios.html">export_scenarios</a></b>(x, path, dirs = NULL, na = ".", file_type = "txt", ...)</div>
    <pre class="tree">gblup/
&#9500;&#9472; 2.1.st_sp/
&#9474;  &#9500;&#9472; param_est_data/adg/A/data.txt
&#9474;  &#9492;&#9472; cv_data/adg/A/Repeat01/Fold1/
&#9474;     &#9500;&#9472; train.txt
&#9474;     &#9492;&#9472; validate.txt
&#9500;&#9472; 2.2.st_mp/  &hellip;
&#9492;&#9472; 2.5.mt_bt/  &hellip;</pre>
    <table>
      <tr><th>{L("Program", "软件")}</th><th>{L("Arguments", "参数")}</th></tr>
      <tr><td>ASReml</td><td><code>na = "."</code></td></tr>
      <tr><td>HIBLUP</td><td><code>na = "NA"</code></td></tr>
      <tr><td>DMU</td><td><code>na = "-9999", col.names = FALSE</code> {L("(numeric codes)", "（全部数值编码）")}</td></tr>
    </table>
    <pre><code>export_scenarios(sc, path = "gblup", na = ".",
  dirs = c(st_sp = "2.1.st_sp",
           mt_bt = "2.5.mt_bt"))
fwrite(folds, "gblup/cv_folds.txt")   # keep it</code></pre>
  </div>
</section>'''

    # -- summarise ------------------------------------------------------------------
    rs = [[0.31, 0.27, 0.35, 0.29, 0.33], [0.30, 0.34, 0.28, 0.32, 0.31]]
    rows_r = "".join(
        strip(f"Repeat{r + 1}", [q("va r", f"{x:.2f}".lstrip("0")) for x in vals] + [f'<span class="arrow">&rarr;</span>{q("mean r", f"{sum(vals) / 5:.2f}".lstrip("0"))}'])
        for r, vals in enumerate(rs))
    p_sum = f'''
<section class="panel st">
  <h2>{L("Summarise accuracy", "汇总预测准确性")} <small>{L("folds &rarr; repeats &rarr; models", "折 &rarr; 重复 &rarr; 模型")}</small></h2>
  <div class="fn">
    <p>{L("Folds of one repeat share most training animals: average them first, then report mean &plusmn; SD over repeats.",
          "同一次重复内各折共享大部分训练个体：先在重复内对各折取平均，再报告各次重复的均值 &plusmn; 标准差。")}</p>
    {rows_r}
    {strip("&hellip;", [])}
    <p>{L("Compare two scenarios <b>paired by repeat</b> (valid because the validation animals are identical):",
          "比较两个场景时<b>按重复配对</b>（因为验证个体相同，这样做才有效）：")}</p>
    <pre><code>by_rep &lt;- res[, .(r = mean(r)),
              by = .(scenario, name, herd, rep)]
by_rep[, .(mean_r = mean(r), sd_r = sd(r)),
       by = .(scenario, name, herd)]
paired &lt;- dcast(by_rep,
  name + herd + rep ~ scenario, value.var = "r")
paired[, t.test(st_mp - st_sp)$p.value,
       by = .(name, herd)]</code></pre>
  </div>
</section>'''

    # -- interactive -----------------------------------------------------------------
    p_try = f'''
<section class="panel mt wide" id="try">
  <h2>{L("Try it", "动手看看")} <small>{L("20 + 16 animals, 5 folds, 3 repeats", "20 + 16 个个体，5 折，3 次重复")}</small></h2>
  <div class="fn">
    <div class="controls">
      <div class="ctl"><span>{L("Scenario", "场景")}</span><div class="seg" data-k="sc">
        <button data-v="st_sp" class="on">st_sp</button><button data-v="st_mp">st_mp</button><button data-v="mt_sp">mt_sp</button><button data-v="mt_mp">mt_mp</button><button data-v="mt_bt">mt_bt</button></div></div>
      <div class="ctl"><span>{L("Target group", "目标群体")}</span><div class="seg" data-k="tg"><button data-v="A" class="on">A</button><button data-v="B">B</button></div></div>
      <div class="ctl"><span>{L("Repeat", "重复")}</span><div class="seg" data-k="rp"><button data-v="1" class="on">1</button><button data-v="2">2</button><button data-v="3">3</button></div></div>
      <div class="ctl"><span>{L("Fold", "折")}</span><div class="seg" data-k="fd"><button data-v="1" class="on">1</button><button data-v="2">2</button><button data-v="3">3</button><button data-v="4">4</button><button data-v="5">5</button></div></div>
      <div class="ctl"><span>{L("Colour by", "着色")}</span><div class="seg" data-k="cb"><button data-v="role" class="on">{L("role", "用途")}</button><button data-v="fold">{L("fold", "折号")}</button></div></div>
    </div>
    <div class="try-grid">
      <div id="try-board"></div>
      <div class="try-side">
        <div class="kv"><span>{L("columns", "列")}</span><b id="try-cols"></b></div>
        <div class="kv"><span>{L("training records", "训练集记录")}</span><b id="try-ntr"></b></div>
        <div class="kv"><span>{L("validation records", "验证集记录")}</span><b id="try-nva"></b></div>
        <div class="cap">{L("validation IDs", "验证个体")}</div>
        <div id="try-ids" class="ids"></div>
        <div class="note" id="try-note"></div>
      </div>
    </div>
    <p class="hint">{L("Switch the scenario: the orange validation animals never change &mdash; only what goes into the training set does. Two-trait scenarios show each animal as two halves (value1 | value2); hatched halves are missing phenotypes, which are kept.",
                       "切换场景时，橙色的验证个体始终不变，变化的只是训练集包含哪些记录。两性状场景中每个个体分成左右两半（value1 | value2）；斜线表示表型缺失，这些行同样保留。")}</p>
  </div>
</section>'''

    try_js = f'''
(function () {{
  var T = {{ same: {json.dumps(L("Same validation animals in all five scenarios for this group, repeat and fold.", "对这个群体、重复和折，五个场景的验证个体完全相同。"), ensure_ascii=False)},
            ref: {json.dumps(L('Other group: all records added to training (ref = "others").', '另一群体：全部记录加入训练集（ref = "others"）。'), ensure_ascii=False)},
            noref: {json.dumps(L('Other group: not used (ref = "none").', '另一群体：不使用（ref = "none"）。'), ensure_ascii=False)} }};
  function rng(a) {{ return function () {{ a |= 0; a = a + 0x6D2B79F5 | 0; var t = Math.imul(a ^ a >>> 15, 1 | a);
    t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; }}; }}
  function shuffle(x, r) {{ for (var i = x.length - 1; i > 0; i--) {{ var j = Math.floor(r() * (i + 1)); var t = x[i]; x[i] = x[j]; x[j] = t; }} return x; }}
  var N = {{ A: 20, B: 16 }}, R = rng(2026), herds = ["A", "B"], animals = {{}}, folds = {{}};
  herds.forEach(function (h) {{
    animals[h] = [];
    for (var i = 1; i <= N[h]; i++) animals[h].push({{ id: h + (i < 10 ? "0" : "") + i, m1: R() < 0.15, m2: R() < 0.2 }});
  }});
  for (var r = 1; r <= 3; r++) {{ folds[r] = {{}}; herds.forEach(function (h) {{
    var lab = []; for (var i = 0; i < N[h]; i++) lab.push(i % 5 + 1); folds[r][h] = shuffle(lab, R); }}); }}
  var st = {{ sc: "st_sp", tg: "A", rp: "1", fd: "1", cb: "role" }};
  var cols = {{ st_sp: "id | herd | sex | value", st_mp: "id | herd | sex | value", mt_sp: "id | herd | sex | value1 | value2",
               mt_mp: "id | herd | sex | value1 | value2", mt_bt: "id | herd | sex | A | B" }};
  function draw() {{
    var ref = st.sc !== "st_sp" && st.sc !== "mt_sp", two = st.sc === "mt_sp" || st.sc === "mt_mp";
    var html = "", ntr = 0, nva = 0, vids = [];
    herds.forEach(function (h) {{
      html += '<div class="strip"><span class="lab">' + h + (h === st.tg ? " &#9679;" : "") + '</span><span class="cells">';
      animals[h].forEach(function (a, i) {{
        var f = folds[st.rp][h][i], role;
        if (h === st.tg) role = (String(f) === st.fd) ? "va" : "tr"; else role = ref ? "tr" : "un";
        if (role === "tr") ntr++; if (role === "va") {{ nva++; vids.push(a.id); }}
        var cls = st.cb === "fold" ? "f" + f : role;
        var tip = a.id + " \\u00b7 Fold" + f + " \\u00b7 " + role;
        if (two) html += '<i class="q big split ' + cls + '" title="' + tip + '"><b class="' + (a.m1 ? "na" : "") + '"></b><b class="' + (a.m2 ? "na" : "") + '"></b><em>' + a.id.slice(1) + '</em></i>';
        else html += '<i class="q big ' + cls + (a.m1 ? " na" : "") + '" title="' + tip + '"><em>' + a.id.slice(1) + '</em></i>';
      }});
      html += "</span></div>";
    }});
    document.getElementById("try-board").innerHTML = html;
    document.getElementById("try-cols").textContent = cols[st.sc];
    document.getElementById("try-ntr").textContent = ntr;
    document.getElementById("try-nva").textContent = nva;
    document.getElementById("try-ids").textContent = vids.join(" ");
    document.getElementById("try-note").textContent = T.same + " " + (ref ? T.ref : T.noref);
  }}
  var segs = document.querySelectorAll("#try .seg");
  for (var s = 0; s < segs.length; s++) (function (seg) {{
    seg.addEventListener("click", function (e) {{
      var b = e.target.closest("button"); if (!b) return;
      var bs = seg.querySelectorAll("button"); for (var i = 0; i < bs.length; i++) bs[i].classList.remove("on");
      b.classList.add("on"); st[seg.getAttribute("data-k")] = b.getAttribute("data-v"); draw();
    }});
  }})(segs[s]);
  draw();
}})();'''

    flow = f'''
<section class="flow five" aria-label="workflow">
  <div class="files"><div class="step">{L("Phenotypes", "表型数据")}</div><div class="fns">id &middot; herd &middot; traits</div></div>
  <div class="cv"><div class="step">1 &middot; {L("Split", "划分")}</div><div class="fns">cv_folds()</div></div>
  <div class="cv"><div class="step">2 &middot; {L("Build", "生成")}</div><div class="fns">cv_scenarios()<br>apply_folds()</div></div>
  <div class="io"><div class="step">3 &middot; {L("Write", "导出")}</div><div class="fns">export_scenarios()</div></div>
  <div class="st"><div class="step">4 &middot; {L("Summarise", "汇总")}</div><div class="fns">{L("mean per repeat", "按重复平均")}</div></div>
</section>'''

    title = L("Cross-validation for genomic evaluation", "基因组评估的交叉验证划分")
    desc = L("How mintyr splits data for comparing GBLUP models: one individual-level fold table, five scenarios, input files and accuracy summaries.",
             "mintyr 如何为比较 GBLUP 模型划分数据：一张个体层面的折表、五个场景、软件输入文件与准确性汇总。")
    return f'''<!doctype html>
<html lang="{"zh-CN" if zh else "en"}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>mintyr &middot; {title}</title>
<meta name="description" content="{desc}">
<link rel="icon" href="favicon.ico">
<!-- Generated by dev/cv_cheatsheet.py: edit that script, not this file. -->
<style>{BASE_CSS}{EXTRA_CSS}</style>
</head>
<body>
<div class="wrap">

<header class="top">
  <img src="reference/figures/logo.svg" alt="mintyr logo" onerror="this.style.display='none'">
  <div>
    <h1>{title} <span class="ver">v{VERSION}</span></h1>
    <p>{desc}</p>
  </div>
  <nav class="links">
    <a href="index.html">{L("Home", "首页")}</a>
    <a href="{article}">{L("Article", "教程文章")}</a>
    <a href="{main_cs}">{L("Main cheat sheet", "总速查表")}</a>
    <a href="{other}" hreflang="{"en" if zh else "zh-CN"}">{L("中文", "English")}</a>
    <button type="button" onclick="window.print()">{L("Print / PDF", "打印 / PDF")}</button>
  </nav>
</header>
{flow}
{legend}

<h2 class="sec">{L("1 &middot; Make one fold table", "1 &middot; 建立一张折表")}</h2>
<main class="grid g3">{p_folds}{p_why}{p_strata}</main>

<h2 class="sec">{L("2 &middot; Build training and validation sets", "2 &middot; 生成训练集与验证集")}</h2>
{p_cards}
<main class="grid g3">{p_apply}{p_export}{p_sum}</main>

<h2 class="sec">{L("3 &middot; See it move", "3 &middot; 交互演示")}</h2>
{p_try}

<footer>
  <span>mintyr {VERSION} &middot; MIT license &middot; Guo Meng</span>
  <span><a href="{article}">{L("Genomic evaluation article", "基因组评估教程")}</a> &middot; <a href="{main_cs}">{L("Main cheat sheet", "总速查表")}</a> &middot; <a href="https://github.com/tony2015116/mintyr/issues">{L("Report an issue", "反馈问题")}</a></span>
</footer>
</div>

<script>{HL_JS}</script>
<script>{try_js}</script>
</body>
</html>
'''


EXTRA_CSS = r"""
/* ---------- cv cheat sheet: block diagrams ---------- */
:root {
  --f1: #d3e4f5; --f1b: #8fb4d9; --f2: #d5eed9; --f2b: #8ec79a; --f3: #fbe2c6; --f3b: #e2ad72;
  --f4: #e6dbf4; --f4b: #b49ad6; --f5: #f6d3dc; --f5b: #dc93a6;
  --tr: #cfe9d7; --trb: #2a6e3f; --va: #f6c99f; --vab: #a8571a; --hatch: rgba(29,38,33,.28);
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --f1: #203548; --f1b: #5d8bb5; --f2: #1f3a26; --f2b: #5fa871; --f3: #47311a; --f3b: #c08647;
    --f4: #322646; --f4b: #9177b8; --f5: #46242e; --f5b: #b8687e;
    --tr: #1f3a28; --trb: #6fc28a; --va: #5a3516; --vab: #e39a5f; --hatch: rgba(227,235,229,.35);
  }
}
:root[data-theme="dark"] {
  --f1: #203548; --f1b: #5d8bb5; --f2: #1f3a26; --f2b: #5fa871; --f3: #47311a; --f3b: #c08647;
  --f4: #322646; --f4b: #9177b8; --f5: #46242e; --f5b: #b8687e;
  --tr: #1f3a28; --trb: #6fc28a; --va: #5a3516; --vab: #e39a5f; --hatch: rgba(227,235,229,.35);
}
.flow.five { grid-template-columns: repeat(5, 1fr); }
.sec { margin: 22px 0 10px; font-size: 13px; letter-spacing: .1em; text-transform: uppercase; color: var(--muted); }
.legend {
  display: flex; flex-wrap: wrap; align-items: center; gap: 6px; font-size: 12.5px; color: var(--muted);
  background: var(--paper); border: 1px solid var(--line); border-radius: 12px; padding: 8px 14px;
}
.legend .sep { width: 1px; height: 18px; background: var(--line); margin: 0 6px; }
.q {
  display: inline-flex; align-items: center; justify-content: center; position: relative; overflow: hidden;
  width: 18px; height: 18px; margin: 1px; border-radius: 4px; border: 1.5px solid var(--line);
  font: 600 9.5px/1 ui-monospace, Menlo, Consolas, monospace; font-style: normal; color: var(--ink); vertical-align: middle;
}
.q.f1 { background: var(--f1); border-color: var(--f1b); } .q.f2 { background: var(--f2); border-color: var(--f2b); }
.q.f3 { background: var(--f3); border-color: var(--f3b); } .q.f4 { background: var(--f4); border-color: var(--f4b); }
.q.f5 { background: var(--f5); border-color: var(--f5b); }
.q.tr { background: var(--tr); border-color: var(--trb); }
.q.va { background: var(--va); border-color: var(--vab); }
.q.un { background: transparent; border-style: dashed; opacity: .6; }
.q.na, .q b.na, .mini .na-c { background-image: repeating-linear-gradient(45deg, transparent 0 3px, var(--hatch) 3px 4px); }
.q.r, .q.mean { width: 30px; font-size: 9px; }
.q.mean { background: var(--st-soft); border-color: var(--st); color: var(--st); }
.q.big { width: 26px; height: 26px; border-radius: 5px; }
.q em { font-style: normal; font-size: 9px; position: relative; z-index: 1; }
.q.split b { position: absolute; top: 0; bottom: 0; width: 50%; }
.q.split b:first-child { left: 0; border-right: 1px solid var(--line); } .q.split b + b { right: 0; }
.strip { display: flex; align-items: center; gap: 6px; margin: 2px 0; }
.strip .lab { font: 11px/1.2 ui-monospace, Menlo, Consolas, monospace; color: var(--muted); min-width: 64px; }
.strip .cells { display: flex; flex-wrap: wrap; align-items: center; }
.cap { font-size: 11px; color: var(--muted); margin: 6px 0 2px; }
.vs { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.vs .strip .lab { min-width: 26px; }
.vs .q { width: 13px; height: 13px; font-size: 8px; margin: 0.5px; border-width: 1px; }
.grid.g3 { columns: auto; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; align-items: start; }
.grid.g3 .panel { margin: 0; }
.bad { color: #b3261e; font-weight: 700; } .good { color: var(--mint); font-weight: 700; }
.new { font-size: 9.5px; color: var(--cv); border: 1px solid currentColor; border-radius: 3px; padding: 0 3px; }
.folds-row { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 6px; }
.fbox { border: 1px dashed var(--line); border-radius: 6px; padding: 2px 6px 4px; }
.mini .a { background: #cfe9d7; } .mini .b { background: #d6e7f5; }
.wide { display: block; margin-bottom: 16px; }
.cards { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 12px; margin-top: 10px; }
.card { border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px; background: var(--paper); }
.card-h { display: flex; flex-direction: column; gap: 2px; }
.card-h code { font-size: 14px; font-weight: 700; color: var(--cv); }
.card-h span { font-size: 12.5px; font-weight: 600; }
.card .model { margin: 4px 0 6px; font-size: 12.5px; color: var(--muted); min-height: 3.2em; }
.card .strip .lab { min-width: 14px; }
.card .q { width: 14px; height: 14px; }
.kv { display: flex; justify-content: space-between; gap: 8px; font-size: 12.5px; border-bottom: 1px dashed var(--line); padding: 2px 0; }
.kv span { color: var(--muted); }
pre.tree { font-size: 12px; line-height: 1.45; }
.controls { display: flex; flex-wrap: wrap; gap: 10px 18px; }
.ctl { display: flex; align-items: center; gap: 6px; font-size: 12.5px; color: var(--muted); }
.seg { display: inline-flex; border: 1px solid var(--line); border-radius: 8px; overflow: hidden; }
.seg button {
  font: 12px/1 ui-monospace, Menlo, Consolas, monospace; padding: 6px 9px; border: 0; border-right: 1px solid var(--line);
  background: var(--paper); color: var(--ink); cursor: pointer;
}
.seg button:last-child { border-right: 0; }
.seg button.on { background: var(--mint); color: var(--paper); }
.try-grid { display: grid; grid-template-columns: minmax(0, 2fr) minmax(220px, 1fr); gap: 18px; margin-top: 12px; align-items: start; }
#try-board .strip .lab { min-width: 34px; font-size: 12px; }
.ids { font: 11.5px/1.5 ui-monospace, Menlo, Consolas, monospace; color: var(--cv); word-break: break-word; }
.hint { color: var(--muted); font-size: 12.5px; }
@media (max-width: 1100px) { .cards { grid-template-columns: repeat(3, minmax(0, 1fr)); } .grid.g3 { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (max-width: 900px) {
  .flow.five { grid-template-columns: repeat(3, 1fr); }
  .try-grid { grid-template-columns: 1fr; }
}
@media (max-width: 640px) {
  .cards { grid-template-columns: 1fr; }
  .vs { grid-template-columns: 1fr; }
  .grid.g3 { grid-template-columns: 1fr; }
  .flow.five { grid-template-columns: 1fr 1fr; }
}
@media print {
  .cards { grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 6px; }
  .card { padding: 6px 8px; }
  #try .controls, #try .hint { display: none; }
  .sec { margin: 8px 0 4px; }
  .grid.g3 { grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; }
}
"""

if __name__ == "__main__":
    for lang, name in [("en", "cv-cheatsheet.html"), ("zh", "cv-cheatsheet-zh.html")]:
        (ROOT / "pkgdown/assets" / name).write_text(build(lang), encoding="utf-8")
        print("wrote", name)
